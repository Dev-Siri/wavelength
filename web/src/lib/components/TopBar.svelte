<script lang="ts">
  import { signIn, signOut } from "@auth/sveltekit/client";
  import "flag-icons/css/flag-icons.min.css";
  import { LogOut } from "lucide-svelte";

  import userStore from "$lib/stores/user.svelte";
  import { codeToCountryName } from "$lib/utils/countries";

  import Image from "./Image.svelte";
  import SearchBar from "./SearchBar.svelte";
  import { Button } from "./ui/button";
  import * as DropdownMenu from "./ui/dropdown-menu";
  import * as Tooltip from "./ui/tooltip";
  import GoogleLogo from "./vectors/GoogleLogo.svelte";

  const { region }: { region: string } = $props();
</script>

<header
  class="flex items-center z-50 justify-between py-3 bg-black fixed w-full pr-[23.5%] rounded-bl-2xl"
>
  <div class="w-1/2 pl-2">
    <SearchBar />
  </div>
  {#if !userStore.user}
    <Button onclick={() => signIn("google")} class="gap-1">
      <GoogleLogo />
      Sign in with Google
    </Button>
  {:else}
    <div class="flex items-center gap-2">
      <Tooltip.Root>
        <Tooltip.Trigger>
          <span class="select-none fi fi-{region.toLowerCase()}"></span>
        </Tooltip.Trigger>
        <Tooltip.Content>
          {@const countryName = codeToCountryName(region)}
          <p>{countryName.charAt(0).toUpperCase()}{countryName.slice(1)}</p>
        </Tooltip.Content>
      </Tooltip.Root>
      <DropdownMenu.Root>
        <DropdownMenu.Trigger>
          <div class="flex items-center gap-2">
            {#if userStore.user.image}
              <Image
                src={userStore.user.image}
                alt="{userStore.user.name}'s Avatar'"
                height={40}
                width={40}
                class="rounded-full"
              />
            {/if}
          </div>
        </DropdownMenu.Trigger>
        <DropdownMenu.Content>
          <DropdownMenu.Label class="text-end text-xl leading-none">
            {userStore.user.name}
          </DropdownMenu.Label>
          <DropdownMenu.Label class="text-end text-sm font-normal -mt-2">
            {userStore.user.email ?? ""}
          </DropdownMenu.Label>
          <DropdownMenu.Separator />
          <DropdownMenu.Item
            onclick={() => signOut()}
            class="py-3 pr-40 gap-1 items-center text-red-500"
          >
            <LogOut size={16} />
            Logout
          </DropdownMenu.Item>
        </DropdownMenu.Content>
      </DropdownMenu.Root>
    </div>
  {/if}
</header>
