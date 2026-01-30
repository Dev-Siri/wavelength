<script lang="ts">
  import { ArrowLeft, DownloadIcon, HouseIcon } from "@lucide/svelte";
  import { isTauri } from "@tauri-apps/api/core";

  import userStore from "$lib/stores/user.svelte.js";

  import GoogleLoginButton from "./action-buttons/GoogleLoginButton.svelte";
  import SearchBar from "./search/SearchBar.svelte";
  import Button from "./ui/button/button.svelte";
  import UserProfileIcon from "./UserProfileIcon.svelte";
</script>

<header
  class="flex items-center z-50 justify-between py-3 bg-black/35 backdrop-blur-xl backdrop-saturate-150 px-4 {isTauri() &&
    'pt-8'}"
>
  <a
    href="/app"
    class="flex items-center w-fit p-4 py-2 duration-200 rounded-full hover:bg-primary-foreground"
  >
    <span class="font-black text-5xl select-none">λ</span>
  </a>
  <div class="flex gap-2 items-center w-1/2 pl-2">
    <Button onclick={() => history.back()} variant="secondary" class="rounded-full">
      <ArrowLeft />
    </Button>
    <Button href="/" variant="secondary" class="rounded-full">
      <HouseIcon />
    </Button>
    <SearchBar />
  </div>
  {#if !userStore.user}
    <GoogleLoginButton />
  {:else}
    <div class="flex items-center self-end gap-2">
      {#if !isTauri()}
        <Button
          href="/downloads"
          class="flex gap-2 items-center text-muted-foreground"
          variant="ghost"
        >
          <DownloadIcon />
          <p class="text-md">Install App</p>
        </Button>
      {/if}
      <UserProfileIcon />
    </div>
  {/if}
</header>
