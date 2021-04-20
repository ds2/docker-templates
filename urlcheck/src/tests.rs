#[cfg(test)]
mod tests {
    // Note this useful idiom: importing names from outer (for mod tests) scope.
    use super::*;
    use crate::{urlExists, readCsvData};

    #[test]
    fn test_urlExists() {
        let url=url::Url::parse("https://www.google.com/").unwrap();
        assert_eq!(urlExists(&url), true);
    }

    #[test]
    fn test_urlExists2() {
        let url=url::Url::parse("https://www.pcwelt.de/").unwrap();
        assert_eq!(urlExists(&url), true);
    }

    #[test]
    fn test_runWithCsvFile(){
        let csvFilePath = std::path::Path::new("test.csv");
        readCsvData(csvFilePath);
    }
}
