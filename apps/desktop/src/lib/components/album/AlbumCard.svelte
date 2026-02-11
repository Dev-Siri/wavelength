<script lang="ts">
  import type { Album } from "$lib/utils/validation/albums";

  import { getReadableAlbumType } from "$lib/utils/format";

  import Image from "../Image.svelte";
  import * as Tooltip from "../ui/tooltip";

  const { album }: { album: Album } = $props();
</script>

<a
  href="/app/album/{album.albumId}"
  class="flex flex-col gap-2 h-64 items-center cursor-pointer group"
  aria-label={`Album card for ${album.title} by ${album.artist.title}`}
>
  <div class="flex flex-col relative">
    <span class="absolute z-10 bg-black/70 text-xs self-end m-2 py-0.5 px-2 rounded-md">
      {getReadableAlbumType(album.albumType)} • {album.releaseDate}
    </span>
    <div class="flex flex-col absolute z-10 self-start justify-end h-full">
      <span class="text-xs bg-black/70 m-2 py-0.5 px-2 rounded-md">
        {album.artist.title}
      </span>
    </div>
    <div class="h-full w-full aspect-square rounded-2xl relative inline-block">
      <Image
        src={album.thumbnail}
        alt="Album {album.title}'s Thumbnail"
        height={192}
        width={192}
        class="object-cover aspect-square group-hover:opacity-60 duration-200 shadow-black h-full w-full rounded-xl"
      />
    </div>
  </div>
  <Tooltip.Root>
    <Tooltip.Trigger>
      <p class="text-ellipsis w-full text-secondary-foreground text-sm text-center">
        {album.title.length > 28 ? `${album.title.slice(0, 28)}...` : album.title}
      </p>
    </Tooltip.Trigger>
    <Tooltip.Content>
      <p>{album.title}</p>
    </Tooltip.Content>
  </Tooltip.Root>
</a>
