<script lang="ts">
  import type { Album } from "$lib/utils/validation/albums";

  import { getReadableAlbumType } from "$lib/utils/format";

  import ArtistLink from "./ArtistLink.svelte";
  import Image from "./Image.svelte";
  import Button from "./ui/button/button.svelte";

  const { album }: { album: Album } = $props();
</script>

<div class="flex items-center gap-4">
  {#key album.thumbnail}
    <Image
      src={album.thumbnail}
      alt="Album {album.title}'s Thumbnail"
      height={128}
      width={128}
      class="h-32 w-32 rounded-xl"
    />
  {/key}
  <div>
    <p class="text-2xl font-medium text-wrap pt-2">{album.title}</p>
    <p class="text-wrap text-white text-sm">
      {getReadableAlbumType(album.albumType)}
      <span class="text-muted-foreground"> by </span>
      <ArtistLink {...album.artist} class="text-white mr-0" />
      <span class="text-muted-foreground">•</span>
      {album.releaseDate}
    </p>
    <div class="flex gap-2 mt-4">
      <Button href={`/app/album/${album.albumId}`} variant="secondary">View</Button>
    </div>
  </div>
</div>
