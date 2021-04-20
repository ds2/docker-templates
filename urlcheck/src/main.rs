use std::error::Error;
use std::io;
use std::process;
use log::{info, trace, warn};

extern crate pretty_env_logger;
#[macro_use] extern crate log;

use serde::Deserialize;

#[derive(Debug, Deserialize)]
struct Record {
    url: String,
    timeout: Option<u8>,
}

fn readCsvData() -> Result<(), Box<dyn Error>> {
    let mut rdr = csv::Reader::from_reader(io::stdin());
    for result in rdr.deserialize() {
        // The iterator yields Result<StringRecord, Error>, so we check the
        // error here.
        let thisUrl: Record = result?;
        trace!("{:?}", thisUrl);
    }
    Ok(())
}

fn main() {
    pretty_env_logger::init();
    info!("Url Checker");
}
