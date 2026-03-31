<script lang="ts">
  import useArtistQuery from "$lib/queries/artist";

  import Image from "../Image.svelte";
  import { Skeleton } from "../ui/skeleton";

  const { browseId }: { browseId: string } = $props();

  const artistQuery = $derived(useArtistQuery(browseId));
</script>

{#if artistQuery.isLoading}
  <div class="h-full w-full">
    <Skeleton />
  </div>
{:else if artistQuery.isSuccess}
  {@const { artist } = artistQuery.data}
  <div class="relative h-full w-full overflow-hidden">
    <Image
      src={artist.thumbnail}
      alt="Artist Preview Image"
      height={200}
      width={200}
      class="absolute inset-0 h-full w-full object-cover"
    />
    <div class="absolute inset-0 bg-black/70 z-10 flex flex-col justify-end p-4">
      <span class="text-xl font-semibold text-white">{artist.title}</span>
      <span class="text-sm text-muted-foreground">{artist.audience} subscribers</span>
    </div>
  </div>
{/if}
