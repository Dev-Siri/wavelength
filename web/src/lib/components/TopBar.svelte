<script lang="ts">
  import { DownloadIcon } from "@lucide/svelte";
  import { useQueryClient } from "@tanstack/svelte-query";
  import "flag-icons/css/flag-icons.min.css";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import userStore from "$lib/stores/user.svelte.js";
  import { codeToCountryName } from "$lib/utils/countries.js";

  import GoogleLoginButton from "./GoogleLoginButton.svelte";
  import SearchBar from "./SearchBar.svelte";
  import Button from "./ui/button/button.svelte";
  import * as Tooltip from "./ui/tooltip";
  import UserProfileIcon from "./UserProfileIcon.svelte";

  const queryClient = useQueryClient();
  const region = $derived.by(() => queryClient.getQueryData<string>(svelteQueryKeys.region));
</script>

<header
  class="flex items-center z-50 justify-between py-3 bg-black absolute right-0 left-0 pr-4 rounded-bl-2xl"
>
  <div class="w-1/2 pl-2">
    <SearchBar />
  </div>
  {#if !userStore.user}
    <GoogleLoginButton />
  {:else}
    <div class="flex items-center self-end gap-2">
      {#if region}
        <Tooltip.Root>
          <Tooltip.Trigger>
            <span class="select-none fi fi-{region.toLowerCase()}"></span>
          </Tooltip.Trigger>
          <Tooltip.Content>
            {@const countryName = codeToCountryName(region)}
            <p>{countryName.charAt(0).toUpperCase()}{countryName.slice(1)}</p>
          </Tooltip.Content>
        </Tooltip.Root>
      {/if}
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
