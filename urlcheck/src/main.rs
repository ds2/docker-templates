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

use std::env;
use std::error::Error;
use std::process::{Command, exit};
use std::time::Duration;
use std::vec::Vec;

use log::{info, warn};
use reqwest::redirect::Policy;
use serde::Deserialize;

mod tests;

#[derive(Debug, Deserialize)]
pub struct Record {
    url: String,
    timeout: Option<u64>,
    method: Option<String>,
}

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

fn main() {
    pretty_env_logger::init();
    info!("Url Checker");
    let default_timeout_str = env::var("URL_TIMEOUT").unwrap_or("30".into_string());
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
    for this_record in records_under_test {
        let url = url::Url::parse(&this_record.url);
        if url.is_ok() {
            let this_url = url.unwrap();
            info!("Checking url {} with t0={:?}", this_url, this_record.timeout);
            if url_exists(&this_url, this_record.timeout.unwrap_or(default_timeout)) {
                info!("- looks good :)");
            } else {
                warn!("- not good :(");
                failed_records.push(this_record);
            }
        } else {
            warn!("Error when parsing url: {}", url.err().unwrap());
            failed_records.push(this_record);
        }
    }
    // failedRecords.push(Record {
    //     url: "http://www.mytesturl".to_string(),
    //     timeout: None,
    //     method: None,
    // });
    if !failed_records.is_empty() {
        let urls: Vec<String> = failed_records.into_iter().map(|r| r.url).collect();
        error!("The following record(s) are/is failing: {}", urls.join(" "));
        let fail_cmd = env::var("ON_EACH_FAIL");
        if fail_cmd.is_ok() {
            info!("Calling external program to report urls");
            let fail_cmd2 = fail_cmd.unwrap();
            for url in urls {
                let output = Command::new(&fail_cmd2)
                    .arg(url)
                    .output();
                println!("{:?}", output.unwrap())
            }
        } else {
            exit(1);
        }
    }
    info!("Done :)")
}
