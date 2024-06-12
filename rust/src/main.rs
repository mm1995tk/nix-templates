extern crate rustc_version_runtime;
fn main() {
    println!(
        "Hello, {}! This was compiled using {}.",
        std::env::var("DUMMY").expect("set env-var DUMMY"),
        rustc_version_runtime::version().to_string()
    );
}
