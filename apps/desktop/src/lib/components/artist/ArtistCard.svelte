<script lang="ts">
  import type { FollowedArtist } from "$lib/utils/validation/artist-response";

  import Image from "../Image.svelte";

  const {
    thumbnail,
    browseId,
    name,
    height = 128,
    width = 128,
    showName,
  }: Pick<FollowedArtist, "thumbnail" | "browseId" | "name"> & {
    height?: number;
    width?: number;
    showName?: boolean;
  } = $props();
</script>

<a
  href="/app/artist/{browseId}"
  role="button"
  tabindex={0}
  title={name}
  class="flex flex-col items-center cursor-pointer duration-200 my-0.5 aspect-square rounded-xl gap-2 hover:opacity-50"
>
  <Image
    src={thumbnail}
    alt="Artist Cover"
    {height}
    {width}
    class="rounded-full aspect-square object-cover duration-200"
  />
  {#if showName}
    <p>{name}</p>
  {/if}
</a>
