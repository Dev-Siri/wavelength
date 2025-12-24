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

Navigate to `/server`.

### Building The Docker Image

Make sure you have Docker installed on your system.
Then you can build the docker image, and run it, specifying the `PORT` and `--env-file`.

```sh
$ docker build . -t wavelength/server
$ docker run -p 8080:8080 -e PORT=8080 --env-file=.env.docker wavelength/server
```

### Manual Setup

You will need Go 1.22+ installed on your system, and the GeoLite2-Country database from [MaxMind](https://maxmind.com/en). Get it by registering for a free MaxMind account [here](https://maxmind.com/en/geolite2/signup), after which you can download specifically the `GeoLite2-Country` database.
Create a directory named `lib` and place the database file in it.

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
