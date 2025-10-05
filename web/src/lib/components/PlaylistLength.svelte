<script lang="ts">
  import type { PlaylistTrackLength } from "$lib/utils/validation/playlist-track";

  const { playlistTrackLength }: { playlistTrackLength: PlaylistTrackLength } = $props();

  const { songCount, songDurationSecond } = playlistTrackLength;

  const minutes = Math.round(songDurationSecond / 60);
  const hours = Math.round(minutes / 60);
  const seconds = songDurationSecond % 60;

  const greaterUnitValue = minutes > 59 ? hours : minutes;
  const greaterUnitText = minutes > 59 ? "hr" : "min";
  const lesserUnitValue = minutes > 59 ? hours : seconds;
  const lesserUnitText = minutes > 59 ? "min" : "sec";
</script>

{#if songCount > 0 && songDurationSecond > 0}
  <span class="text-muted-foreground">•</span>
  <span class="text-muted-foreground font-normal">
    {songCount}
    {songCount === 1 ? "song" : "songs"}, {greaterUnitValue}
    {greaterUnitText}
    {lesserUnitValue}
    {lesserUnitText}
  </span>
{/if}
