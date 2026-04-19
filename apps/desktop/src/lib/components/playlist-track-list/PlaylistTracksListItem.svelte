<script lang="ts">
  import type { Playlist, PlaylistTrack } from "$lib/schemas/playlist";
  import type { MusicPlaylistContextSource } from "$lib/stream-player/queue/MusicQueue";

  import Track from "../track/Track.svelte";

  const {
    isRearrangingList,
    context,
    music,
    playlist,
    isPreLiked,
    index,
  }: {
    isRearrangingList: boolean;
    context: MusicPlaylistContextSource;
    music: PlaylistTrack;
    playlist: Playlist;
    isPreLiked?: boolean;
    index: number;
  } = $props();
</script>

<div class={isRearrangingList ? "pointer-events-none select-none" : ""}>
  <Track
    {isPreLiked}
    {music}
    toggle={{ type: "remove", from: playlist }}
    {context}
    positionInList={index + 1}
  />
</div>
