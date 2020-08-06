extern crate wascc_actor as actor;
extern crate serde;
extern crate wascc_codec as codec;

use actor::prelude::*;
use serde::Serialize;

#[derive(Serialize)]
struct HelloResponse{
    original: String,
    response: String,
}

actor_handlers!{
    codec::http::OP_HANDLE_REQUEST => hello,
    codec::core::OP_HEALTH_REQUEST => healthy
}

fn healthy(_req: codec::core::HealthRequest) -> HandlerResult<()> {
    Ok(())
}

fn hello(req: codec::http::Request) -> HandlerResult<codec::http::Response> {
    let qs = req.query_string;
    let resp = String::from("Hello, world!");

    let response = HelloResponse{
        original: qs,
        response: resp,
    };

    Ok(codec::http::Response::json(response, 200, "OK"))
}