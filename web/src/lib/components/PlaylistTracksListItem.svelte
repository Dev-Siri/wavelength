<script lang="ts">
  import { fade } from "svelte/transition";

  import type { PlayListTrack } from "$lib/db/schema.js";

  import TrackItem from "./TrackItem.svelte";

  const {
    i,
    isRearrangingList,
    music,
  }: { i: number; isRearrangingList: boolean; music: PlayListTrack } = $props();
</script>

<div class="flex items-center gap-2">
  <p
    class="text-lg px-2 text-muted-foreground select-none hover:bg-secondary duration-200 rounded-full flex flex-col items-center justify-center h-8 w-8 text-center {isRearrangingList
      ? 'animate-bounce'
      : ''}"
    in:fade
    out:fade
  >
    {i + 1}
  </p>
  <div class="w-full {isRearrangingList ? 'pointer-events-none' : ''}">
    <TrackItem {music} />
  </div>
</div>
