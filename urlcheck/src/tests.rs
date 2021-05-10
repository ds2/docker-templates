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
    use crate::uc_methods::{parse_tag_string, read_csv_data};

// #[test]
    // fn test_urlExists() {
    //     let url = url::Url::parse("https://www.google.com/").unwrap();
    //     assert_eq!(test_url(url_exists(&url),5000,"GET",), true);
    // }
    //
    // #[test]
    // fn test_urlExists2() {
    //     let url = url::Url::parse("https://www.pcwelt.de/").unwrap();
    //     assert_eq!(url_exists(&url), true);
    // }

    #[test]
    fn test_run_with_csv_file() {
        let csv_file_path = std::path::Path::new("test.csv");
        let datasets = &mut vec![];
        read_csv_data(csv_file_path, datasets).expect("Error when reading the CSV!");
    }

    #[test]
    fn test_no_tags() {
        let mytagstring = None;
        let tags = parse_tag_string(mytagstring, ';');
        assert_eq!(tags.len(), 0)
    }
}
