<script lang="ts">
  import type { FullArtist } from "$lib/utils/validation/artist-response";

  import AlbumCard from "$lib/components/album/AlbumCard.svelte";

  const { artist }: { artist: FullArtist } = $props();
</script>

<div class="px-2 pb-20">
  <h4 class="text-xl font-semibold select-none my-2">Albums</h4>
  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 px-2">
    {#each artist.albums as album}
      <AlbumCard album={{ ...album, artist }} />
    {/each}
  </div>
</div>
