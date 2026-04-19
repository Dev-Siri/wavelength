<script>
  import PlaylistTrackListHeader from "../playlist-track-list/PlaylistTrackListHeader.svelte";
  import TrackSkeleton from "./TrackSkeleton.svelte";
</script>

<div class="h-fit" id="playlist-track-list-skeleton">
  <PlaylistTrackListHeader />
  {#each new Array(15)}
    <TrackSkeleton />
  {/each}
</div>
