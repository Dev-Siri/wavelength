<script lang="ts">
  import type { PlaylistTracksLength } from "../../routes/api/playlists/[playlistId]/length/types";

  export let playlistTrackLength: PlaylistTracksLength;

  const { songCount, songDurationSecond } = playlistTrackLength;

  const minutes = Math.round(songDurationSecond / 60);
  const seconds = songDurationSecond % 60;
</script>

{#if songCount > 0 && songDurationSecond > 0}
  <span class="text-muted-foreground">•</span>
  <span class="text-muted-foreground font-normal">
    {songCount}
    {songCount === 1 ? "song" : "songs"}, {minutes} min {seconds} sec
  </span>
{/if}
