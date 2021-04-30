/*
    URLCheck - a dummy url check program to check if some urls are online
    Copyright (C) 2021  Dirk Strauss

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#[macro_use]
extern crate log;
extern crate pretty_env_logger;
extern crate reqwest;
extern crate simple_error;

use std::env;
use std::error::Error;
use std::process::{Command, exit};
use std::sync::{Arc, Barrier};
use std::sync::mpsc::channel;
use std::time::Duration;
use std::vec::Vec;

use chrono::prelude::*;
use log::{info, warn};
use reqwest::redirect::Policy;
use serde::Deserialize;
use simple_error::bail;
use threadpool::ThreadPool;

mod tests;

#[derive(Debug, Deserialize)]
pub struct Record {
    url: String,
    timeout: Option<u64>,
    method: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct TestResponse {
    url: String,
    duration: u64,
    response_code: u16,
    // 0 means client connect error
    connection_error: bool,
}

type BoxResult<T> = Result<T, Box<dyn Error>>;


pub fn test_url(url: &url::Url, t0: u64) -> Result<TestResponse, Box<dyn Error>> {
    let client = reqwest::blocking::Client::builder()
        .timeout(Option::Some(Duration::from_secs(t0)))
        .redirect(Policy::limited(20))
        .build().unwrap();
    let start_time = Local::now();
    let res = client.get(url.to_string()).send();
    let end_time = Local::now();
    let duration = end_time.signed_duration_since(start_time).to_std().unwrap();
    let mut response_object = TestResponse {
        url: url.to_string(),
        duration: duration.as_millis() as u64,
        response_code: 0,
        connection_error: false,
    };
    if res.is_ok() {
        let http_status_code = res.unwrap().status();
        debug!("Status for {}: {}", url, http_status_code);
        response_object.response_code = http_status_code.as_u16();
        if http_status_code.as_u16() >= 400 {
            warn!("- The url {} returned status code {}!!", url, http_status_code)
        }
    } else {
        warn!("- Error when connecting to url: {:?}", res.err().unwrap());
        response_object.connection_error = true
    }
    Ok(response_object)
}

#[deprecated]
pub fn url_exists(url: &url::Url, t0: u64) -> bool {
    let client = reqwest::blocking::Client::builder()
        .timeout(Option::Some(Duration::from_secs(t0)))
        .redirect(Policy::limited(20))
        .build().unwrap();
    let res = client.get(url.to_string()).send();
    if res.is_ok() {
        let http_status_code = res.unwrap().status();
        debug!("Status for {}: {}", url, http_status_code);
        let was_successful = http_status_code.as_u16() < 400;
        if !was_successful {
            warn!("- The url {} returned status code {}!!", url, http_status_code)
        }
        return was_successful;
    } else {
        warn!("- Error when connecting to url: {:?}", res.err().unwrap())
    }
    return false;
}

pub fn read_csv_data(path: &std::path::Path, records: &mut Vec<Record>) -> Result<(), Box<dyn Error>> {
    debug!("Will test with csv from {:?}", path);
    let mut rdr = csv::Reader::from_path(path).unwrap();
    for result in rdr.deserialize() {
        // The iterator yields Result<StringRecord, Error>, so we check the
        // error here.
        let this_url: Record = result?;
        debug!("{:?}", this_url);
        records.push(this_url)
    }
    Ok(())
}

pub fn report_url(response: &TestResponse) -> BoxResult<()> {
    if !response.connection_error && response.response_code < 400 {
        info!("Result: {} -> HTTP {} in {}ms", response.url, response.response_code, response.duration);
    } else {
        //could be an error
        let fail_cmd = env::var("ON_EACH_FAIL");
        if fail_cmd.is_ok() {
            let fail_cmd2 = fail_cmd.unwrap();
            let output = Command::new(&fail_cmd2)
                .arg(response.url.to_string())
                .arg(response.duration.to_string())
                .arg(response.response_code.to_string())
                .arg(response.connection_error.to_string())
                .output();
            let o2 = output.unwrap();
            info!("{:?}", o2);
            if o2.status.code().unwrap() > 0 {
                // error!("The command to report the error errored as well. Will give up here, sry.");
                bail!("The command exited with error! Please check your alert script!");
            }
        } else {
            warn!("No fail command given. Will ignore reporting for url {}!", response.url)
        }
    }
    Ok(())
}

fn main() {
    pretty_env_logger::init();
    info!("Url Checker");
    let default_timeout_str = env::var("URL_TIMEOUT").unwrap_or("30".to_string());
    let default_timeout: u64 = default_timeout_str.parse().unwrap();
    let csv_file = env::var("CSV_FILE").unwrap_or("/to_check/urls.csv".to_string());
    let csv_file_path = std::path::Path::new(&csv_file);
    let mut records_under_test = Vec::new();
    let mut failed_records = Vec::new();

    if csv_file_path.exists() {
        read_csv_data(csv_file_path, &mut records_under_test).unwrap();
    } else {
        //assert we try a single url
        let one_url_record = Record {
            url: env::var("URL").unwrap_or("http://localhost/".to_string()),
            timeout: None,
            method: Option::Some("GET".to_string()),
        };
        records_under_test.push(one_url_record);
    }
    info!("Starting tests..");
    let n_workers = 2;
    let pool = ThreadPool::new(n_workers);
    let (tx, rx) = channel();
    let barrier = Arc::new(Barrier::new(records_under_test.len() + 1));
    for this_record in records_under_test {
        let url = url::Url::parse(&this_record.url);
        if url.is_ok() {
            let this_url = url.unwrap();
            let tx_cloned = tx.clone();
            let barrier_cloned = barrier.clone();
            pool.execute(move || {
                info!("Checking url {} with t0={:?}", this_url, this_record.timeout);
                let test_result = test_url(&this_url, this_record.timeout.unwrap_or(default_timeout));
                if test_result.is_ok() {
                    tx_cloned.send(test_result.unwrap()).expect("Could not push result to TX channel!");
                }
                barrier_cloned.wait();
            });
        } else {
            warn!("Error when parsing url: {}", url.err().unwrap());
            failed_records.push(this_record);
        }
    }
    info!("Waiting for tests to complete..");
    barrier.wait();
    info!("Checking results..");
    let test_responses: Vec<TestResponse> = rx.into_iter().collect();
    debug!("Start iterator for all responses");
    for result in test_responses {
        debug!("Result: {:?}", result);
        if report_url(&result).is_err() {
            error!("the fail command was not given! Will simply crash the execution here to indicate an issue ;)");
            exit(1);
        }
    }
    info!("Done :)")
}
