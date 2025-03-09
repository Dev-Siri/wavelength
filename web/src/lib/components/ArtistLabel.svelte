<script lang="ts">
  import type { Artist } from "$lib/server/api/interface/types";

  import Image from "./Image.svelte";

  const { artist }: { artist: Artist } = $props();
</script>

<a
  href="/artist/{artist.browseId}"
  class="flex flex-col justify-center hover:bg-muted p-4 rounded-2xl duration-200"
>
  <Image
    src={artist.thumbnail}
    alt="Artist Thumbnail"
    height={176}
    width={176}
    class="h-44 w-44 rounded-full"
  />
  <div>
    <p class="text-lg mt-2">{artist.title}</p>
    <p class="text-muted-foreground text-sm">Artist - {artist.subscriberText}</p>
  </div>
</a>
