<script lang="ts">
  import type { Artist } from "$lib/utils/validation/artist";

  import Image from "./Image.svelte";

  const { artist }: { artist: Artist } = $props();
</script>

<a
  href="/app/artist/{artist.browseId}"
  class="flex justify-center items-center h-fit p-4 hover:opacity-80 duration-200"
>
  {#key artist.thumbnail}
    <Image
      src={artist.thumbnail}
      alt="Artist Thumbnail"
      height={96}
      width={96}
      class="h-24 w-24 rounded-full"
    />
  {/key}
  <div class="ml-4">
    <p class="text-xl mt-2">
      {artist.title.length > 20 ? `${artist.title.slice(0, 19)}...` : artist.title}
    </p>
    <p class="text-muted-foreground text-sm">{artist.subscriberText}</p>
  </div>
</a>
