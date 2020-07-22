use std::fs::File;
use std::io::Read;
use std::path::Path;

fn main() {
    let path = Path::new("/var/run/secrets/kubernetes.io/serviceaccount/namespace");
    let display = path.display();

    let mut file = match File::open(&path) {
        Err(why) => panic!("couldn't open {}: {}", display, why),
        Ok(file) => file,
    };

    let mut contents = String::new();
    file.read_to_string(&mut contents).expect(format!("could not read {}", display).as_str());

    println!("hello world from kubernetes, namespace {}", contents);

    // hack: loop until pod is killed
    loop {

    }

}