<script lang="ts">
  import { resolve } from "$app/paths";

  import type { FollowedArtist } from "$lib/schemas/artist";
  import { getUpscaledArtistThumbnailUrl } from "$lib/utils/url";

  import Image from "../Image.svelte";

  const {
    thumbnail,
    browseId,
    name,
    height = 128,
    width = 128,
    showName,
  }: Pick<FollowedArtist, "thumbnail" | "browseId" | "name"> & {
    audience?: string;
    height?: number;
    width?: number;
    showName?: boolean;
  } = $props();
</script>

<a
  href={resolve(`/app/artist/${browseId}`)}
  role="button"
  tabindex={0}
  title={name}
  class="flex flex-col items-start hover:bg-[#1f1f1f] transition-all cursor-pointer duration-200 aspect-square rounded-xl gap-2 hover:opacity-50 {showName
    ? 'py-4 my-0.5'
    : ''}"
>
  <Image
    src={getUpscaledArtistThumbnailUrl(thumbnail)}
    alt="Artist Cover"
    {height}
    {width}
    class="rounded-full aspect-square object-cover duration-200 {showName ? 'h-full w-full' : ''}"
  />
  {#if showName}
    <p class="text-xl">{name}</p>
    <p class="text-xs text-muted-foreground font-medium bg-secondary py-0.5 px-1 rounded-sm">
      Artist
    </p>
  {/if}
</a>
