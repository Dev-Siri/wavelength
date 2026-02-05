use std::{net::SocketAddr, path::Path, thread};

use axum::{
    body::Body,
    extract::Query,
    http::{HeaderMap, HeaderValue},
    response::{IntoResponse, Result},
    routing::get,
    Router,
};
use reqwest::{Client, StatusCode};
use serde::Deserialize;
use tokio::{fs::File, net::TcpListener};
use tokio_util::io::ReaderStream;
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
                .route("/local-playback", get(local_handler))
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

async fn local_handler(
    Query(q): Query<StreamQuery>,
    headers: HeaderMap,
) -> Result<impl IntoResponse> {
    let file_path = Path::new(&q.url);

    if !file_path.exists() {
        return Ok((
            StatusCode::NOT_FOUND,
            HeaderMap::new(),
            Body::from("Stream not found."),
        ));
    }

    let file = File::open(file_path).await.map_err(|e| e.to_string())?;

    let metadata = file.metadata().await.map_err(|e| e.to_string())?;

    let file_size = metadata.len();

    let mut response_headers = HeaderMap::new();
    response_headers.insert("Accept-Ranges", HeaderValue::from_static("bytes"));
    response_headers.insert(
        "Content-Length",
        HeaderValue::from_str(&file_size.to_string()).unwrap(),
    );

    if let Some(range) = headers.get("range") {
        if let Ok(range_str) = range.to_str() {
            if let Some(range_str) = range_str.strip_prefix("bytes=") {
                if let Some((start, end)) = range_str.split_once('-') {
                    let start: u64 = start.parse().unwrap_or(0);
                    let end: u64 = if end.is_empty() {
                        file_size - 1
                    } else {
                        end.parse().unwrap_or(file_size - 1)
                    };

                    let length = end.saturating_sub(start) + 1;

                    let mut file = File::open(file_path).await.map_err(|e| e.to_string())?;

                    use tokio::io::{AsyncReadExt, AsyncSeekExt};

                    file.seek(std::io::SeekFrom::Start(start))
                        .await
                        .map_err(|e| e.to_string())?;

                    let mut buffer = vec![0u8; length as usize];
                    file.read_exact(&mut buffer)
                        .await
                        .map_err(|e| e.to_string())?;

                    let mut range_headers = response_headers.clone();

                    range_headers.insert(
                        "Content-Range",
                        HeaderValue::from_str(&format!("bytes {}-{}/{}", start, end, file_size))
                            .unwrap(),
                    );

                    range_headers.insert(
                        "Content-Length",
                        HeaderValue::from_str(&length.to_string()).unwrap(),
                    );

                    return Ok((
                        StatusCode::PARTIAL_CONTENT,
                        range_headers,
                        Body::from(buffer),
                    ));
                }
            }
        }
    }

    let stream = ReaderStream::new(file);

    Ok((StatusCode::OK, response_headers, Body::from_stream(stream)))
}
