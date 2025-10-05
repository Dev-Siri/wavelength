<script lang="ts">
  import type { PlaylistTrack } from "$lib/utils/validation/playlist-track";

  import TrackItem from "./TrackItem.svelte";

  const {
    isRearrangingList,
    music,
  }: { i: number; isRearrangingList: boolean; music: PlaylistTrack } = $props();
</script>

<div class="w-full {isRearrangingList ? 'pointer-events-none' : ''}">
  <TrackItem {music} />
</div>
