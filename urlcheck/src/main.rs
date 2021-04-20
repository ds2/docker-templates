#[macro_use]
extern crate log;
extern crate pretty_env_logger;
extern crate reqwest;

use std::env;
use std::error::Error;
use std::io;
use std::process;
use std::process::{Command, exit};
use std::time::Duration;
use std::vec::Vec;

use log::{info, trace, warn};
use reqwest::redirect::Policy;
use reqwest::StatusCode;
use serde::Deserialize;
use url::Url;

mod tests;

#[derive(Debug)]
enum HttpMethods {
    GET,
    HEAD,
    POST,
    PUT,
    DELETE,
}

#[derive(Debug, Deserialize)]
pub struct Record {
    url: String,
    timeout: Option<u8>,
    method: Option<String>,
}

pub fn urlExists(url: &url::Url) -> bool {
    let client = reqwest::blocking::Client::builder()
        .timeout(Option::Some(Duration::from_secs(30)))
        .redirect(Policy::limited(20))
        .build().unwrap();
    let res = client.get(url.to_string()).send();
    if res.is_ok() {
        let httpStatusCode = res.unwrap().status();
        debug!("Status for {}: {}", url, httpStatusCode);
        let wasSuccessful = httpStatusCode.as_u16() < 400;
        if !wasSuccessful {
            warn!("- The url {} returned status code {}!!", url, httpStatusCode)
        }
        return wasSuccessful;
    }
    return false;
}

pub fn readCsvData(path: &std::path::Path, records: &mut Vec<Record>) -> Result<(), Box<dyn Error>> {
    debug!("Will test with csv from {:?}", path);
    let mut rdr = csv::Reader::from_path(path).unwrap();
    for result in rdr.deserialize() {
        // The iterator yields Result<StringRecord, Error>, so we check the
        // error here.
        let thisUrl: Record = result?;
        debug!("{:?}", thisUrl);
        records.push(thisUrl)
    }
    Ok(())
}

fn main() {
    pretty_env_logger::init();
    info!("Url Checker");
    let csvFile = env::var("CSV_FILE").unwrap_or("/to_check/urls.csv".to_string());
    let csvFilePath = std::path::Path::new(&csvFile);
    let mut recordsUnderTest = Vec::new();
    let mut failedRecords = Vec::new();

    if csvFilePath.exists() {
        readCsvData(csvFilePath, &mut recordsUnderTest);
    } else {
        //assert we try a single url
        let oneUrlRecord = Record {
            url: env::var("URL").unwrap_or("http://localhost/".to_string()),
            timeout: None,
            method: Option::Some("GET".to_string()),
        };
        recordsUnderTest.push(oneUrlRecord);
    }
    info!("Starting tests..");
    for thisRecord in recordsUnderTest {
        let url = url::Url::parse(&thisRecord.url);
        if url.is_ok() {
            let thisUrl = url.unwrap();
            info!("Checking url {}", thisUrl);
            if urlExists(&thisUrl) {
                info!("- looks good :)");
            } else {
                warn!("- not good :(");
                failedRecords.push(thisRecord);
            }
        } else {
            warn!("Error when parsing url: {}", url.err().unwrap());
            failedRecords.push(thisRecord);
        }
    }
    // failedRecords.push(Record {
    //     url: "http://www.mytesturl".to_string(),
    //     timeout: None,
    //     method: None,
    // });
    if !failedRecords.is_empty() {
        let urls: Vec<String> = failedRecords.into_iter().map(|r| r.url).collect();
        error!("The following records are failing: {}", urls.join(" "));
        let failCmd = env::var("ON_EACH_FAIL");
        if failCmd.is_ok() {
            info!("Calling external program to report urls");
            let failCmd2 = failCmd.unwrap();
            for url in urls {
                let output = Command::new(&failCmd2)
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
