<script lang="ts">
  import { goto } from "$app/navigation";
  import { page } from "$app/state";

  import Button from "$lib/components/ui/button/button.svelte";
  import AlbumSearch from "./album-search.svelte";
  import ArtistSearch from "./artist-search.svelte";
  import PlaylistSearch from "./playlist-search.svelte";
  import TrackSearch from "./track-search.svelte";
  import VideoSearch from "./video-search.svelte";

  const searchTypes = ["tracks", "videos", "artists", "playlists", "albums"];

  const q = $derived.by(() => page.url.searchParams.get("q") ?? "");
  const currentSearchType = $derived.by(() => page.url.searchParams.get("type"));

  $effect(() => {
    if (!q) goto("/");

    if (!currentSearchType || !searchTypes.includes(currentSearchType))
      goto(`/app/search?q=${encodeURIComponent(q)}&type=tracks`);
  });
</script>

<div class="h-screen p-4 overflow-auto bg-black pb-[20%]">
  <section class="flex items-center gap-4 mt-4">
    {#each searchTypes as searchType}
      <Button
        href={`/app/search?q=${encodeURIComponent(q)}&type=${encodeURIComponent(searchType)}`}
        variant={searchType === currentSearchType ? "default" : "secondary"}
      >
        {searchType.charAt(0).toUpperCase()}{searchType.slice(1)}
      </Button>
    {/each}
  </section>
  <div class="flex w-full gap-5 mt-8 mb-16">
    {#if currentSearchType === "tracks"}
      <TrackSearch {q} />
    {:else if currentSearchType === "videos"}
      <VideoSearch {q} />
    {:else if currentSearchType === "artists"}
      <ArtistSearch {q} />
    {:else if currentSearchType === "playlists"}
      <PlaylistSearch {q} />
    {:else if currentSearchType === "albums"}
      <AlbumSearch {q} />
    {/if}
  </div>
</div>
