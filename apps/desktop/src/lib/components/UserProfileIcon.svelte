<script lang="ts">
  import { localStorageKeys } from "$lib/constants/keys";
  import userStore from "$lib/stores/user.svelte.js";

  import Image from "./Image.svelte";
  import * as DropdownMenu from "./ui/dropdown-menu";

  function handleSignout() {
    localStorage.removeItem(localStorageKeys.authToken);
    localStorage.removeItem(localStorageKeys.authUser);
    userStore.user = null;
    userStore.authToken = null;
  }
</script>

{#if userStore.user}
  <DropdownMenu.Root>
    <DropdownMenu.Trigger class="cursor-pointer hover:opacity-80 duration-200">
      <div class="flex items-center gap-2">
        {#if userStore.user.pictureUrl}
          <Image
            src={userStore.user.pictureUrl}
            alt="{userStore.user.displayName}'s Avatar'"
            height={40}
            width={40}
            class="rounded-full"
          />
        {/if}
      </div>
    </DropdownMenu.Trigger>
    <DropdownMenu.Content>
      <DropdownMenu.Item onclick={handleSignout} class="pr-40">Log out</DropdownMenu.Item>
    </DropdownMenu.Content>
  </DropdownMenu.Root>
{/if}
