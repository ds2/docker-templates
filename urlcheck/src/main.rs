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

use std::{env, thread};
use std::error::Error;
use std::process::{Command, exit};
use std::sync::mpsc::channel;
use std::time::Duration;
use std::vec::Vec;

use chrono::prelude::*;
use log::{info, warn};
use reqwest::redirect::Policy;

use crate::uc_methods::{parse_tag_string, report_url, read_csv_data, test_url};
use crate::uc_types::{CsvRecord, TestResponse, TestResult, BoxResult};
use std::borrow::Borrow;

mod uc_types;
mod tests;
mod uc_methods;

impl TestResult for TestResponse {
    fn was_successful(&self) -> bool {
        return !self.connection_error && self.response_code < 400 && self.response_code > 0;
    }
    fn not_successful(&self) -> bool {
        return self.connection_error || self.response_code >= 400;
    }
}

fn main() {
    pretty_env_logger::init();
    info!("Url Checker");
    let retry_count: u8 = env::var("RETRY_COUNT").unwrap_or("2".to_string()).parse().expect("Retry count could not be parsed!");
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
        let one_url_record = CsvRecord {
            url: env::var("URL").unwrap_or("http://localhost/".to_string()),
            timeout: None,
            method: Some("GET".to_string()),
            tags: None,
        };
        records_under_test.push(one_url_record);
    }
    info!("Starting tests..");
    let (tx, rx) = channel();
    let pool_handle = thread::spawn(move || {
        for this_record in records_under_test {
            let url = url::Url::parse(&this_record.url);
            if url.is_ok() {
                let this_url = url.unwrap();
                let http_method = this_record.method.unwrap_or("GET".to_string());
                let max_timeout_value = this_record.timeout.unwrap_or(default_timeout);
                let tags = parse_tag_string(this_record.tags, ' ');
                let tx_cloned = tx.clone();
                thread::spawn(move || {
                    info!("Checking url {} with t0={:?}", this_url, max_timeout_value);
                    let mut test_result = test_url(&this_url, max_timeout_value, http_method.borrow(), &tags);
                    for _ in 1..retry_count {
                        if test_result.not_successful() {
                            debug!("test before was unsuccessful, try retest..");
                            thread::sleep(Duration::from_secs(5));
                            test_result = test_url(&this_url, max_timeout_value, http_method.borrow(), &tags);
                        } else {
                            break;
                        }
                    }
                    debug!("done with check thread");
                    tx_cloned.send(test_result).expect("Could not push result to TX channel!");
                });
            } else {
                warn!("Error when parsing url: {}", url.err().unwrap());
                failed_records.push(this_record);
            }
        }
    });

    info!("Waiting for tests to complete..");
    pool_handle.join().unwrap();
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

