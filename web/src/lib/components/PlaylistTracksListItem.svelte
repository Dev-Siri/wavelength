<script lang="ts">
  import { fade } from "svelte/transition";

  import type { PlayListTrack } from "$lib/db/schema";

  import TrackItem from "./TrackItem.svelte";

  export let i: number;
  export let isRearrangingList: boolean;
  export let music: PlayListTrack;
</script>

<div class="flex items-center gap-2">
  <p
    class="text-lg px-2 text-muted-foreground hover:bg-gray-900 duration-200 rounded-full h-7 w-7 text-center {isRearrangingList
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
