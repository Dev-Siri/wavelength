<script lang="ts">
  import { signOut } from "@auth/sveltekit/client";
  import { LogOutIcon } from "@lucide/svelte";

  import userStore from "$lib/stores/user.svelte";

  import Image from "./Image.svelte";
  import * as DropdownMenu from "./ui/dropdown-menu";
</script>

{#if userStore.user}
  <DropdownMenu.Root>
    <DropdownMenu.Trigger class="cursor-pointer hover:opacity-80 duration-200">
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
        <LogOutIcon size={16} />
        Logout
      </DropdownMenu.Item>
    </DropdownMenu.Content>
  </DropdownMenu.Root>
{/if}
