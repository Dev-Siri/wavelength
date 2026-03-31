<script lang="ts">
  import { resolve } from "$app/paths";

  import type { SavedAlbum } from "$lib/schemas/album";
  import { getReadableAlbumType } from "$lib/utils/format";

  import Image from "../Image.svelte";

  const {
    title,
    albumCover,
    albumId,
    albumType,
    albumDuration,
    mode,
  }: SavedAlbum & {
    mode: "card" | "icon";
  } = $props();
</script>

<a
  href={resolve(`/app/album/${albumId}`)}
  role="button"
  tabindex={0}
  {title}
  class="flex group cursor-pointer items-center p-2.5 pr-3 bg-[#111] hover:bg-[#1c1c1c] duration-200 my-0.5 rounded-xl w-full gap-2 {mode ===
  'icon'
    ? 'justify-center'
    : 'justify-start'}"
>
  <Image
    src={albumCover}
    alt="Artist Cover"
    height={80}
    width={80}
    class="rounded-sm h-15 w-15 aspect-square object-cover group-hover:opacity-50 duration-200"
  />
  {#if mode === "card"}
    <div class="text-start">
      <p class="text-md font-semibold">{title}</p>
      <p class="text-xs text-muted-foreground font-medium bg-secondary py-0.5 px-1 mt-0.5 w-fit">
        {getReadableAlbumType(albumType)} • {albumDuration}
      </p>
    </div>
  {/if}
</a>
