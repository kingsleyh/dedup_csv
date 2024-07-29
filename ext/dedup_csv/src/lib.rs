use std::error::Error;
use std::ffi::OsStr;
use std::fs::File;
use std::path::Path;
use csv::{StringRecord, Writer};
use magnus::{define_module, function, prelude::*, Ruby};

fn dedup(ruby: &Ruby, previous_csv_path: String, new_csv_path: String, target_path: String) -> magnus::error::Result<()> {
    if !previous_csv_path.has_extension(&["csv"]) {
        return Err(magnus::Error::new(ruby.exception_standard_error(), "previous_csv_path must be a csv file".to_string()));
    }
    if !new_csv_path.has_extension(&["csv"]) {
        return Err(magnus::Error::new(ruby.exception_standard_error(), "new_csv_path must be a csv file".to_string()));
    }

    let csv1 = File::open(previous_csv_path).map_err(|e| magnus_err(ruby, e, "previous_csv_path"))?;
    let csv2 = File::open(new_csv_path).map_err(|e| magnus_err(ruby, e, "new_csv_path"))?;

    let mut previous_csv: csv::Reader<File> = csv::Reader::from_reader(csv1);
    let mut new_csv: csv::Reader<File> = csv::Reader::from_reader(csv2);

    let mut wtr = Writer::from_path(target_path).map_err(|e| magnus_err(ruby, e, "target_path"))?;

    let previous_headers = previous_csv.headers().map_err(|e| magnus_err(ruby, e, "previous_csv_path headers"))?;
    let new_headers = new_csv.headers().map_err(|e| magnus_err(ruby, e, "new_csv_path headers"))?;

    if previous_headers != new_headers {
        return Err(magnus::Error::new(ruby.exception_standard_error(), "headers of both csv files must be the same".to_string()));
    }

    wtr.write_byte_record(previous_headers.as_byte_record()).unwrap();

    let mut previous_records = vec![];
    for previous_record in previous_csv.records() {
        let previous_record = previous_record.map_err(|e| magnus_err(ruby, e, "previous_record"))?;
        let previous_record = previous_record.into_iter().map(|r| r.trim_end()).collect::<StringRecord>();
        previous_records.push(previous_record)
    }

    for new_record in new_csv.records() {
        let new_record = new_record.map_err(|e| magnus_err(ruby, e, "new_record"))?;
        let new_record = new_record.into_iter().map(|r| r.trim_end()).collect::<StringRecord>();
        if !previous_records.contains(&new_record) {
            wtr.write_byte_record(new_record.as_byte_record()).unwrap();
        }
    }

    wtr.flush().unwrap();

    Ok(())
}

fn magnus_err<E: Error>(ruby: &Ruby, e: E, msg: &str) -> magnus::Error {
    magnus::Error::new(ruby.exception_standard_error(), format!("{}: {}", msg, e.to_string()))
}

#[magnus::init]
fn init() -> Result<(), magnus::Error> {
    let module = define_module("DedupCsv")?;
    module.define_singleton_method("dedup", function!(dedup, 3))?;
    Ok(())
}

pub trait FileExtension {
    fn has_extension<S: AsRef<str>>(&self, extensions: &[S]) -> bool;
}

impl<P: AsRef<Path>> FileExtension for P {
    fn has_extension<S: AsRef<str>>(&self, extensions: &[S]) -> bool {
        if let Some(ref extension) = self.as_ref().extension().and_then(OsStr::to_str) {
            return extensions
                .iter()
                .any(|x| x.as_ref().eq_ignore_ascii_case(extension));
        }

        false
    }
}
