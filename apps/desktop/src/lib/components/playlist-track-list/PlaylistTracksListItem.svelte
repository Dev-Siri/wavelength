<script lang="ts">
  import type { Playlist, PlaylistTrack } from "$lib/schemas/playlist";
  import type { MusicPlaylistContextSource } from "$lib/stream-player/queue/MusicQueue";

  import TrackItem from "../track/Track.svelte";

  const {
    isRearrangingList,
    context,
    music,
    playlist,
    isPreLiked,
  }: {
    isRearrangingList: boolean;
    context: MusicPlaylistContextSource;
    music: PlaylistTrack;
    playlist: Playlist;
    isPreLiked?: boolean;
  } = $props();
</script>

<div class="w-full {isRearrangingList ? 'pointer-events-none' : ''}">
  <TrackItem {isPreLiked} {music} toggle={{ type: "remove", from: playlist }} {context} />
</div>
