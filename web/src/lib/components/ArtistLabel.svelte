<script lang="ts">
  import type { Artist } from "$lib/utils/validation/artist";

  import Image from "./Image.svelte";

  const { artist }: { artist: Artist } = $props();
</script>

<a
  href="/app/artist/{artist.browseId}"
  class="flex flex-col justify-center bg-muted/50 items-center h-fit p-4 rounded-2xl hover:bg-muted duration-200"
>
  {#key artist.thumbnail}
    <Image
      src={artist.thumbnail}
      alt="Artist Thumbnail"
      height={144}
      width={144}
      class="h-36 w-36 rounded-full"
    />
  {/key}
  <div class="text-center">
    <p class="text-lg mt-2">
      {artist.title.length > 20 ? `${artist.title.slice(0, 19)}...` : artist.title}
    </p>
    <p class="text-muted-foreground text-sm">{artist.subscriberText}</p>
  </div>
</a>
