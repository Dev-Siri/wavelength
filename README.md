# WaveLength

<img src="./images/brand.png" />

Wavelength is a cross-platform music app. It wraps Rapid API's YT Music API and YouTube's official v3 API. Availabel for both the web (TypeScript + SvelteKit) and mobile. (Dart + Flutter) Backend code is written alongside web svelte client with SvelteKit's API routes. Neon Database, managed with Drizzle.

Didn't wanna make the same mistake like before and overcomplicate the tech stack.

## Getting Started

- Clone the project.

```sh
$ git clone https://github.com/Dev-Siri/wavelength
```

- Go to Web (Main) application & Run it with dev mode.

Make sure you create a `.env.local` file and enter your own credentials as shown in `.env.example`

```sh
$ cd web
$ bun dev
# or
$ pnpm dev
```

- For the Flutter app, navigate to `/mobile`. Make sure you have Flutter and the native tools like Android Studio/XCode installed on your system beforehand.
Make sure to create a `.env` file (NOT `.env.local`) for mobile as well and enter your own credentials as shown in `.env.example` for mobile.

Then you can run the dev command.

```
$ flutter run
```

## License

This project is MIT licensed. See [LICENSE](LICENSE).
