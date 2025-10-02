import os 

def get_yt_cookie_path():
  ytCookiePath = os.getenv("YT_COOKIE_PATH")

  if ytCookiePath is None:
    print("No YT_COOKIE_PATH set. Exiting...")
    exit(1)

  return ytCookiePath