use std::{net::SocketAddr, thread};

use axum::{
    body::Body,
    extract::Query,
    http::HeaderMap,
    response::{IntoResponse, Result},
    routing::get,
    Router,
};
use reqwest::Client;
use serde::Deserialize;
use tokio::net::TcpListener;
use tower_http::cors::{Any, CorsLayer};

const STREAM_SERVER_PORT: u16 = 17842;

pub fn start_stream_server() {
    thread::spawn(|| {
        let rt = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .unwrap();

        rt.block_on(async {
            let cors = CorsLayer::new()
                .allow_origin(Any)
                .allow_methods(Any)
                .allow_headers(Any)
                .expose_headers(Any);

            let app = Router::new()
                .route("/stream-playback", get(stream_handler))
                .layer(cors);
            let addr = SocketAddr::from(([127, 0, 0, 1], STREAM_SERVER_PORT));

            axum::serve(TcpListener::bind(addr).await.unwrap(), app)
                .await
                .unwrap();
        });
    });
}

#[derive(Deserialize)]
struct StreamQuery {
    url: String,
}

async fn stream_handler(
    Query(q): Query<StreamQuery>,
    headers: HeaderMap,
) -> Result<impl IntoResponse> {
    let range = headers.get("range").cloned();
    let client = Client::new();

    let mut request = client.get(q.url);

    if let Some(r) = range {
        request = request.header("Range", r);
    }

    let response = request.send().await.map_err(|e| e.to_string())?;

    let mut stream_headers = response.headers().clone();
    let status = response.status();
    let stream = response.bytes_stream();

    stream_headers.remove("Access-Control-Allow-Origin");

    Ok((status, stream_headers, Body::from_stream(stream)))
}
