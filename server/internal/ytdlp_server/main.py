from typing import Any, cast
from fastapi import FastAPI, Query
from fastapi.responses import PlainTextResponse
import os
import yt_dlp

app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)

TMP_DIR = "/tmp/streams"
os.makedirs(TMP_DIR, exist_ok=True)

def get_yt_cookie_path():
  ytCookiePath = os.getenv("YT_COOKIE_PATH")

  if ytCookiePath is None:
    print("No YT_COOKIE_PATH set. Exiting...")
    exit(1)

  return ytCookiePath

def download_to_tmp(video_id: str, format: str, intent: str) -> str:
  output_path = os.path.join(TMP_DIR, f"{video_id}-{intent}.%(ext)s")

  ydl_opts: dict[str, Any] = {
    "format": format,
    "quiet": True,
    "cookiefile": get_yt_cookie_path(),
    "outtmpl": output_path,
  }

  with yt_dlp.YoutubeDL(cast("Any", ydl_opts)) as ytdlp:
    info = ytdlp.extract_info(f"https://www.youtube.com/watch?v={video_id}")
    final_path = ytdlp.prepare_filename(info)
    return final_path
  
@app.get("/stream-url")
def stream_playback(videoId: str = Query(...), format: str = Query(...), intent: str = Query(...)):
  file_path = download_to_tmp(videoId, format, intent)
  return PlainTextResponse(file_path)
