<script lang="ts">
  import { ArrowLeft, DownloadIcon, HouseIcon } from "@lucide/svelte";

  import userStore from "$lib/stores/user.svelte.js";

  import GoogleLoginButton from "./GoogleLoginButton.svelte";
  import SearchBar from "./SearchBar.svelte";
  import Button from "./ui/button/button.svelte";
  import UserProfileIcon from "./UserProfileIcon.svelte";
</script>

<header
  class="flex items-center z-50 justify-between py-3 bg-black absolute right-0 left-0 pr-4 rounded-bl-2xl"
>
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
      <Button
        href="/downloads"
        class="flex gap-2 items-center text-muted-foreground"
        variant="ghost"
      >
        <DownloadIcon />
        <p class="text-md">Install App</p>
      </Button>
      <UserProfileIcon />
    </div>
  {/if}
</header>
