<script lang="ts">
  import { ChevronUpIcon } from "@lucide/svelte";

  import type { Artist } from "$lib/schemas/artist";
  import type { PlaylistVideoType } from "$lib/schemas/playlist";
  import type { MusicPlaylistContextSource } from "$lib/stream-player/queue/MusicQueue";

  import PlaylistTrackListHeader from "$lib/components/playlist-track-list/PlaylistTrackListHeader.svelte";
  import PlaylistPlayOptions from "$lib/components/playlist/PlaylistPlayOptions.svelte";
  import Track from "$lib/components/track/Track.svelte";
  import Button from "$lib/components/ui/button/button.svelte";

  const { artist, showHome }: { artist: Artist; showHome: () => void } = $props();

  const artistTopSongsQueueable = $derived(
    artist.topSongs.map(track => ({
      ...track,
      videoType: "VIDEO_TYPE_TRACK" as PlaylistVideoType,
    })),
  );

  const context = $derived({
    type: "artistTopSongs",
    browseId: artist.browseId,
    sourceName: artist.title,
  } satisfies MusicPlaylistContextSource);
</script>

<div class="flex flex-col gap-2 px-2 my-4">
  <span class="text-xl font-semibold">Most popular from {artist.title}</span>
  <PlaylistPlayOptions {context} tracks={artistTopSongsQueueable} />
</div>
<div class="pb-[20%]">
  <PlaylistTrackListHeader />
  {#each artist.topSongs as music, i (music.videoId)}
    <Track
      {context}
      {music}
      playCount={music.playCount}
      toggle={{ type: "add" }}
      positionInList={i + 1}
    />
  {/each}
  <div class="w-full flex justify-center">
    <Button variant="ghost" onclick={showHome}>
      <ChevronUpIcon />
    </Button>
  </div>
</div>
