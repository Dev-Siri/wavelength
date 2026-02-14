<script lang="ts">
  import type { FullArtist } from "$lib/utils/validation/artist-response";

  import PlaylistPlayOptions from "$lib/components/playlist/PlaylistPlayOptions.svelte";
  import Track from "$lib/components/track/Track.svelte";

  const { artist }: { artist: FullArtist } = $props();
</script>

<div class="flex items-center justify-between">
  <h4 class="text-xl font-semibold select-none">Popular</h4>
  <PlaylistPlayOptions
    tracks={artist.topSongs.map(track => ({
      ...track,
      artists: [artist],
      videoType: "VIDEO_TYPE_TRACK",
    }))}
  />
</div>
<div class="px-2">
  {#each artist.topSongs as song}
    <Track
      music={{ ...song, artists: [artist], duration: "" }}
      playCount={song.playCount}
      toggle={{ type: "add" }}
    />
  {/each}
</div>
