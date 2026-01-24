<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";
  import { artistResponseSchema } from "$lib/utils/validation/artist-response";

  import Image from "../Image.svelte";
  import { Skeleton } from "../ui/skeleton";

  const { browseId }: { browseId: string } = $props();

  const artistQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.artist(browseId),
    queryFn: () => backendClient(`/artists/artist/${browseId}`, artistResponseSchema),
  }));
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
      <span class="text-3xl text-white">{artist.title}</span>
      <span class="text-md text-muted-foreground">{artist.audience} subscribers</span>
    </div>
  </div>
{/if}
