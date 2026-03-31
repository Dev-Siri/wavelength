<script lang="ts">
  import { resolve } from "$app/paths";
  import {
    ChevronLeftIcon,
    ChevronRightIcon,
    DownloadIcon,
    HouseIcon,
    SettingsIcon,
  } from "@lucide/svelte";
  import { isTauri } from "@tauri-apps/api/core";

  import userStore from "$lib/stores/user.svelte.js";

  import GoogleLoginButton from "./action-buttons/GoogleLoginButton.svelte";
  import Logo from "./Logo.svelte";
  import SearchBar from "./search/SearchBar.svelte";
  import Button from "./ui/button/button.svelte";
  import UserProfileIcon from "./UserProfileIcon.svelte";
</script>

<header
  class="relative flex justify-between items-center bg-[#111] z-50 h-full py-2 backdrop-blur-xl backdrop-saturate-150 px-4"
>
  <a
    href={resolve("/app")}
    class="flex items-center w-fit p-4 py-2 duration-200 rounded-full hover:bg-primary-foreground"
  >
    {#if !isTauri()}
      <Logo />
    {/if}
  </a>
  <div class="flex gap-2 h-full items-center w-1/2 pl-2">
    <Button
      onclick={() => history.back()}
      variant="secondary"
      size="icon"
      class="rounded-full px-4"
    >
      <ChevronLeftIcon />
    </Button>
    <Button
      onclick={() => history.forward()}
      variant="secondary"
      size="icon"
      class="rounded-full px-4"
    >
      <ChevronRightIcon />
    </Button>
    <Button href="/app" variant="secondary" size="icon" class="rounded-full px-4">
      {#if isTauri()}
        <div class="scale-40">
          <Logo />
        </div>
      {:else}
        <HouseIcon />
      {/if}
    </Button>
    <SearchBar />
  </div>
  {#if !userStore.user}
    <GoogleLoginButton />
  {:else}
    <div class="flex items-center gap-2">
      <Button
        href={isTauri() ? "/app/downloads" : "/app/app-link"}
        class="flex gap-2 items-center text-muted-foreground {isTauri() ? 'rounded-full' : ''}"
        title={isTauri() ? "Downloads" : "Install App"}
        variant="ghost"
        size={isTauri() ? "icon" : "default"}
      >
        <DownloadIcon />
        {#if !isTauri()}
          <p class="text-md">Install App</p>
        {/if}
      </Button>
      <Button
        href="/app/settings"
        class="rounded-full"
        title="Settings"
        variant="ghost"
        size="icon"
      >
        <SettingsIcon />
      </Button>
      <UserProfileIcon />
    </div>
  {/if}
</header>
