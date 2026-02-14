<script lang="ts">
  import { ArrowLeft, DownloadIcon, HouseIcon } from "@lucide/svelte";
  import { isTauri } from "@tauri-apps/api/core";

  import userStore from "$lib/stores/user.svelte.js";

  import GoogleLoginButton from "./action-buttons/GoogleLoginButton.svelte";
  import Logo from "./Logo.svelte";
  import SearchBar from "./search/SearchBar.svelte";
  import Button from "./ui/button/button.svelte";
  import UserProfileIcon from "./UserProfileIcon.svelte";
</script>

<header
  class="flex items-center z-50 justify-between h-full py-2 bg-black/35 backdrop-blur-xl backdrop-saturate-150 px-4 {isTauri() &&
    'pt-8'}"
>
  <a
    href="/app"
    class="flex items-center w-fit p-4 py-2 duration-200 rounded-full hover:bg-primary-foreground"
  >
    <Logo />
  </a>
  <div class="flex gap-2 h-full items-center w-1/2 pl-2">
    <Button
      onclick={() => history.back()}
      variant="secondary"
      size="icon"
      class="rounded-full px-4"
    >
      <ArrowLeft />
    </Button>
    <Button href="/" variant="secondary" size="icon" class="rounded-full px-4">
      <HouseIcon />
    </Button>
    <SearchBar />
  </div>
  {#if !userStore.user}
    <GoogleLoginButton />
  {:else}
    <div class="flex items-center self-end gap-2">
      <Button
        href={isTauri() ? "/app/downloads" : "/app/app-link"}
        class="flex gap-2 items-center text-muted-foreground"
        variant="ghost"
      >
        <DownloadIcon />
        {#if !isTauri()}
          <p class="text-md">Install App</p>
        {/if}
      </Button>
      <UserProfileIcon />
    </div>
  {/if}
</header>
