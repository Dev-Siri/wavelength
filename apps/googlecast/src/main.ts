import { mount } from "svelte";

import App from "./App.svelte";

import "./app.css";

const rootElement = document.getElementById("root");

if (!rootElement) throw new Error("#root not found.");

const app = mount(App, { target: rootElement });

export default app;
