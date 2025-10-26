from typing import Any, cast
from fastapi import FastAPI, Query
from env import get_yt_cookie_path
from fastapi.responses import PlainTextResponse, JSONResponse
import os
import yt_dlp

app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)

TMP_DIR = "/tmp/streams"
os.makedirs(TMP_DIR, exist_ok=True)

def download_to_tmp(video_id: str, format: str) -> str:
  suffix = "vid" if "bestvideo" in format else "aud"
  output_path = os.path.join(TMP_DIR, f"{video_id}-{suffix}.%(ext)s")

  ydl_opts: dict[str, Any] = {
    "format": format,
    "quiet": True,
    "noplaylist": True,
    "cookiefile": get_yt_cookie_path(),
    "nocheckcertificate": True,
    "outtmpl": output_path,
    "extractor_args": {
      "youtube": {
        "player_js_version": "actual"
      }
    },
  }

  with yt_dlp.YoutubeDL(cast("Any", ydl_opts)) as ytdlp:
    info = ytdlp.extract_info(f"https://www.youtube.com/watch?v={video_id}")
    final_path = ytdlp.prepare_filename(info)
    return final_path
  
def get_hls_stream(video_id: str):
  ydl_opts: dict[str, Any] = {
    "format": "best[protocol=m3u8_native]",
    "quiet": True,
    "noplaylist": True,
    # "cookiefile": get_yt_cookie_path(),
    "nocheckcertificate": True,
    "source_address": "0.0.0.0",
    "extractor_args": {
      "youtube": {
        "player_client": ["default", "tv"],
        "player_js_version": "actual"
      }
    },
  }

  with yt_dlp.YoutubeDL(cast("Any", ydl_opts)) as ytdlp:
    info = ytdlp.extract_info(f"https://www.youtube.com/watch?v={video_id}", download=False)
    return info.get("formats")

@app.get("/stream-url")
def stream_playback(videoId: str = Query(...), format: str = Query(...)):
  file_path = download_to_tmp(videoId, format)
  return PlainTextResponse(file_path)

@app.get("/stream-hls")
def hls_stream_playback(videoId: str = Query(...)):
  streams = get_hls_stream(videoId)

  if not streams:
    return JSONResponse({ "message": "No streams found." }, 404)
  return JSONResponse({ "streams": streams })