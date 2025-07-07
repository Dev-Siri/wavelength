<script lang="ts">
  import "flag-icons/css/flag-icons.min.css";

  import userStore from "$lib/stores/user.svelte";
  import { codeToCountryName } from "$lib/utils/countries";

  import GoogleLoginButton from "./GoogleLoginButton.svelte";
  import SearchBar from "./SearchBar.svelte";
  import * as Tooltip from "./ui/tooltip";
  import UserProfileIcon from "./UserProfileIcon.svelte";

  const { region }: { region: string } = $props();
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
      <Tooltip.Root>
        <Tooltip.Trigger>
          <span class="select-none fi fi-{region.toLowerCase()}"></span>
        </Tooltip.Trigger>
        <Tooltip.Content>
          {@const countryName = codeToCountryName(region)}
          <p>{countryName.charAt(0).toUpperCase()}{countryName.slice(1)}</p>
        </Tooltip.Content>
      </Tooltip.Root>
      <UserProfileIcon />
    </div>
  {/if}
</header>
