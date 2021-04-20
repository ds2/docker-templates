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
#[cfg(test)]
mod tests {
    // Note this useful idiom: importing names from outer (for mod tests) scope.
    use super::*;
    use crate::{url_exists, read_csv_data};

    #[test]
    fn test_urlExists() {
        let url=url::Url::parse("https://www.google.com/").unwrap();
        assert_eq!(url_exists(&url), true);
    }

    #[test]
    fn test_urlExists2() {
        let url=url::Url::parse("https://www.pcwelt.de/").unwrap();
        assert_eq!(url_exists(&url), true);
    }

    #[test]
    fn test_runWithCsvFile(){
        let csvFilePath = std::path::Path::new("test.csv");
        read_csv_data(csvFilePath);
    }
}
