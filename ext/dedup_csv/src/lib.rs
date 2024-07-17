use magnus::{define_module, function, prelude::*, Error};

fn hello(subject: String) -> String {
    format!("Hello from Rust ext, {}!", subject)
}

fn dedup(csv_1_path: String, csv_2_path: String, target_path: String) -> Result<(), Error> {
    let message = format!("csv_1_path: {}, csv_2_path: {}, target_path: {}", csv_1_path, csv_2_path, target_path);
    println!("{}", message);
    Ok(())
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let module = define_module("DedupCsv")?;
    module.define_singleton_method("hello", function!(hello, 1))?;
    module.define_singleton_method("dedup", function!(dedup, 3))?;
    Ok(())
}
