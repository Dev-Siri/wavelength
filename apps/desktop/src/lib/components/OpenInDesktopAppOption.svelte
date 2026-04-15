<script lang="ts">
  import { isTauri } from "@tauri-apps/api/core";

  /* eslint-disable svelte/no-navigation-without-resolve */
  import * as DropdownMenu from "./ui/dropdown-menu";

  const { link }: { link: `wavlen://${string}` } = $props();
</script>

{#if !isTauri()}
  <DropdownMenu.Item class="p-0">
    <a class="flex items-center justify-between pr-8" href={link} target="_blank">
      <span class="bg-black scale-50 py-2 px-4 aspect-square rounded-xl font-black text-4xl">λ</span
      >
      Open in Desktop app
    </a>
  </DropdownMenu.Item>
{/if}
