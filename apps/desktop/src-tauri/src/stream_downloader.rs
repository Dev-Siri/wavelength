use anyhow::{anyhow, Result};
use reqwest::Client;
use std::sync::Arc;
use tauri::async_runtime;
use tokio::fs::File;
use tokio::io::AsyncSeekExt;
use tokio::sync::Mutex;
use tokio::{fs::OpenOptions, io::AsyncWriteExt};

pub struct StreamDownloader {
    client: Client,
    workers: usize,
}

impl StreamDownloader {
    pub fn new(workers: usize) -> Self {
        Self {
            client: Client::new(),
            workers,
        }
    }

    pub async fn download(&self, url: &str, output: &str) -> Result<()> {
        let response = self.client.head(url).send().await?;
        let len = response
            .headers()
            .get(reqwest::header::CONTENT_LENGTH)
            .ok_or_else(|| anyhow!("Missing Content-Length"))?
            .to_str()?
            .parse::<u64>()?;

        let file = OpenOptions::new()
            .create(true)
            .write(true)
            .truncate(true)
            .open(output)
            .await?;

        file.set_len(len).await?;

        let file = Arc::new(Mutex::new(file));

        let chunk_size = len / self.workers as u64;
        let mut tasks = Vec::new();

        for i in 0..self.workers {
            let start = i as u64 * chunk_size;
            let end = if i == self.workers - 1 {
                len - 1
            } else {
                start + chunk_size - 1
            };

            let url = url.to_string();
            let client = self.client.clone();
            let file = Arc::clone(&file);

            tasks.push(async_runtime::spawn(async move {
                download_range(&client, &url, file, start, end).await
            }));
        }

        for t in tasks {
            t.await??;
        }

        Ok(())
    }
}

async fn download_range(
    client: &Client,
    url: &str,
    file: Arc<Mutex<File>>,
    start: u64,
    end: u64,
) -> Result<()> {
    let range_header = format!("bytes={}-{}", start, end);

    let mut resp = client
        .get(url)
        .header(reqwest::header::RANGE, range_header)
        .send()
        .await?
        .error_for_status()?;

    let mut offset = start;

    while let Some(chunk) = resp.chunk().await? {
        let mut f = file.lock().await;
        f.seek(std::io::SeekFrom::Start(offset)).await?;
        f.write_all(&chunk).await?;
        offset += chunk.len() as u64;
    }

    Ok(())
}
