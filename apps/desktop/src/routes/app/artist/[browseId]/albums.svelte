<script lang="ts">
  import type { Artist } from "$lib/schemas/artist";

  import AlbumCard from "$lib/components/album/AlbumCard.svelte";

  const { artist }: { artist: Artist } = $props();
</script>

<div class="pb-[20%]">
  <h4 class="text-xl font-semibold select-none my-2">Albums by {artist.title}</h4>
  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
    {#each artist.albums as album (album.albumId)}
      <AlbumCard album={{ ...album, artist }} />
    {/each}
  </div>
</div>
