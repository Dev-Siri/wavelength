# WaveLength

<img src="./images/brand.png" />

WaveLength is a cross-platform music app that wraps Rapid API's YouTube Music API and YouTube's official v3 API.

## Getting Started

Clone the project.

```sh
$ git clone https://github.com/Dev-Siri/wavelength
```

> NOTE: Each of these applications have their .env.example (with the server having .env.docker too), make sure you fill these variables before running them.

## Web

Navigate to the `/web` directory, and run the SvelteKit app with dev mode

```sh
$ cd web
$ bun dev
# or
$ pnpm dev
```

## Mobile

Navigate to the `/mobile` directory. Make sure you have [Flutter](https://flutter.dev). You'll also need the native tooling for the platform you're running on: Android requires [Android-Studio](https://developer.android.com/studio) and additional command-line tools and packages installed. iOS requires XCode to be installed on your Mac.
Then you can start the application in dev mode:
```sh
$ flutter run
```

## Server

Navigate to `/server`. Here you'll need a couple of things. One of these are YouTube credentials. Follow the instructions from [yt-dlp](https://github.com/yt-dlp/yt-dlp/wiki/FAQ#how-do-i-pass-cookies-to-yt-dlp)'s wiki page and make sure that you are using a burner YouTube account to not be at risk of termination. You should be retrieving the cookies in Netscape format.

### Building The Docker Image

Make sure you have Docker installed on your system.
The cookies from the `cookies.txt` file need to be converted to base64. You can use this command to get it's base64 form:
```sh
$ base64 -i <cookie.txt-file-path>
```

Once you have gotten the base64 string of the cookies, you need to specify it in your environment, the `.env.docker` file.
Finally you can build the docker image, then run it, specifying the `PORT` and `--env-file`.

```sh
$ docker build . -t wavelength/server
$ docker run -p 8080:8080 -e PORT=8080 --env-file=.env.docker wavelength/server
```

### Manual Setup

You will need Go 1.22+ installed on your system, and the GeoLite2-Country database from [MaxMind](https://maxmind.com/en). Get it by registering for a free MaxMind account [here](https://maxmind.com/en/geolite2/signup), after which you can download specifically the `GeoLite2-Country` database.
Create a directory named `lib` and place the database file in it. Create another directory named `secrets` and place the `cookies.txt` file that you extracted earlier in it.

Then navigate deeper to `internal/ytdlp_server`, and start the `yt-dlp` server, providing it the path to your cookies file.
> [PyPy](https://pypy.org) is used in these example, it is recommended for better performance over standard CPython.
```sh
# Install the required packages with pip before you run it.
$ pypy3 -m pip install -r requirements.txt
# Then you can run it.
$ YT_COOKIE_PATH=../../secrets/cookies.txt pypy3 -m uvicorn main:app --host 0.0.0.0 --port 8000
```

After this, you can navigate back to `/server` and finally run the Go server:
```sh
# Run it directly.
$ go run main.go
# OR: Compile the server to a binary, then run it.
$ go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o ./bin/wavelength .
$ ./bin/wavelength
# OR: Run it using `air` if you have it installed.
$ air
```

## License

This project is MIT licensed. See [LICENSE](LICENSE).
