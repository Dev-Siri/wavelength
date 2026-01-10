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

## Backend

Almost all microservices are entirely written in Go, with one crucial service, the YouTube Scraper, written in TypeScript (Bun) for use of the [`YouTube.js`](https://github.com/LuanRT/YouTube.js) library to retrieve data from the platform.

To run the entirety of the project, you need to have [Docker](https://docker.com) installed on your system. The project includes a `docker-compose.yml` in the `/server` directory. Use the compose commands to start all the microservices up:

```sh
$ cd server
$ docker compose up
# shut all services down
$ docker compose down
```

The microservices use gRPC for communication. If you are looking to make any changes to the protobuf definitions, you need to run `make` to regenerate the gRPC client/server code.

```sh
# generate gRPC definitions
$ make generate
```

Note that the command also runs a `package.json` script with Bun to generate TypeScript definitions. If you do not have Bun installed, then change the `Makefile` to a different JavaScript package manager command.

## License

This project is MIT licensed. See [LICENSE](LICENSE).
