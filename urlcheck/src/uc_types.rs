use std::error::Error;

use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct CsvRecord {
    pub url: String,
    pub timeout: Option<u64>,
    pub method: Option<String>,
    pub tags: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct TestResponse {
    pub url: String,
    pub duration: u64,
    pub response_code: u16,
    // 0 means client connect error
    pub connection_error: bool,
    pub tags: Vec<String>,
}

pub trait TestResult {
    fn was_successful(&self) -> bool;
    fn not_successful(&self) -> bool;
}

pub type BoxResult<T> = Result<T, Box<dyn Error>>;
