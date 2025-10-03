from typing import Any, cast
from fastapi import FastAPI, Query
from env import get_yt_cookie_path
from fastapi.responses import PlainTextResponse
import os
import yt_dlp

app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)

TMP_DIR = "/tmp/streams"
os.makedirs(TMP_DIR, exist_ok=True)

def download_to_tmp(video_id: str, format: str) -> str:
  suffix = "vid" if "bestvideo" in format else "aud"
  output_path = os.path.join(TMP_DIR, f"{video_id}-{suffix}.mp4")

  ydl_opts: dict[str, Any] = {
    "format": format,
    "quiet": True,
    "noplaylist": True,
    "cookiefile": get_yt_cookie_path(),
    "nocheckcertificate": True,
    "outtmpl": output_path,
  }

  with yt_dlp.YoutubeDL(cast("Any", ydl_opts)) as ytdlp:
    ytdlp.download([f"https://www.youtube.com/watch?v={video_id}"])

  return output_path

@app.get("/stream-url")
def stream_playback(videoId: str = Query(...), format: str = Query(...)):
  file_path = download_to_tmp(videoId, format)
  return PlainTextResponse(file_path)