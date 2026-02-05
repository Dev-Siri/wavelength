<script lang="ts">
  import type { PlaylistTrack } from "$lib/utils/validation/playlist-track";
  import type { Playlist } from "$lib/utils/validation/playlists";

  import TrackItem from "../track/Track.svelte";

  const {
    isRearrangingList,
    music,
    playlist,
  }: {
    isRearrangingList: boolean;
    music: PlaylistTrack;
    playlist: Playlist;
  } = $props();
</script>

<div class="w-full {isRearrangingList ? 'pointer-events-none' : ''}">
  <TrackItem {music} toggle={{ type: "remove", from: playlist }} />
</div>
