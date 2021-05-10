use std::env;
use std::error::Error;
use std::process::Command;
use std::time::Duration;

use chrono::Local;
use reqwest::redirect::Policy;
use simple_error::bail;

use crate::uc_types::{BoxResult, CsvRecord, TestResponse};

pub fn parse_tag_string_by_whitespace(tag_string: Option<String>) -> Vec<String> {
    debug!("Got string {:?} to separate", tag_string);
    let tag_string = tag_string.unwrap_or("".to_string());
    let found_tags_splitted = tag_string.split_whitespace();
    return found_tags_splitted.map(|item| (item.to_string())).collect();
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

pub fn read_csv_data(path: &std::path::Path, records: &mut Vec<CsvRecord>) -> Result<(), Box<dyn Error>> {
    debug!("Will test with csv from {:?}", path);
    let mut rdr = csv::Reader::from_path(path).unwrap();
    for result in rdr.deserialize() {
        // The iterator yields Result<StringRecord, Error>, so we check the
        // error here.
        let this_url: CsvRecord = result?;
        debug!("{:?}", this_url);
        records.push(this_url)
    }
    Ok(())
}

pub fn test_url(url: &url::Url, t0: u64, method: &str, tags: &Vec<String>) -> TestResponse {
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
        tags: tags.to_vec(),
    };
    if res.is_ok() {
        let http_status_code = res.unwrap().status();
        debug!("Status for {}: {}", url, http_status_code);
        response_object.response_code = http_status_code.as_u16();
    } else {
        warn!("- Error when connecting to url: {:?}", res.err().unwrap());
        response_object.connection_error = true
    }
    response_object
}

