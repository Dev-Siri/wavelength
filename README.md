# WaveLength

<img src="./images/brand.png" />

Wavelength is a cross-platform music app. It wraps Rapid API's YT Music API and YouTube's official v3 API. Available for both the web, written in TypeScript (SvelteKit) and mobile, written in Dart (Flutter), with the backend code written in Go, deployed to [render.com](https://render.com) using a standardized Docker environment. Uses a PostgreSQL Database, hosted on Neon.

I made the same mistake like before and overcomplicated the tech stack.

## Getting Started

Clone the project.

```sh
$ git clone https://github.com/Dev-Siri/wavelength
```

Go to the web application and run it with dev mode. Make sure you create a `.env.local` file and enter your own credentials as shown in `.env.example`

```sh
$ cd web
$ bun dev
# or
$ pnpm dev
```

For the Flutter app, navigate to `/mobile`. Make sure you have Flutter and the native tools like Android Studio/XCode installed on your system beforehand.
Make sure to create a `.env` file (NOT `.env.local`) for mobile as well and enter your own credentials as shown in `.env.example` for mobile.

Then you can run the dev command.

```sh
$ flutter run
```

Finally to get the application running for real, navigate to `/server` and start the Go server. Again, also make sure to fill the environment variables for the server as well.

```sh
# Run it directly.
$ go run main.go

# OR, compile to a binary, then run it.
$ go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o ./bin/wavelength .
$ ./bin/wavelength

# OR, build the docker image, then run it.
$ docker build . -t wavelength/server
$ docker run -p 8080:8080 -e PORT=8080 --env-file=.env wavelength/server
```

## License

This project is MIT licensed. See [LICENSE](LICENSE).
