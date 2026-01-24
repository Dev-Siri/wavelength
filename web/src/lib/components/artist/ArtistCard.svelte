<script lang="ts">
  import type { FollowedArtist } from "$lib/utils/validation/artist-response";

  import Image from "../Image.svelte";

  const {
    thumbnail,
    browseId,
    name,
    height = 128,
    width = 128,
  }: Pick<FollowedArtist, "thumbnail" | "browseId" | "name"> & {
    height?: number;
    width?: number;
  } = $props();
</script>

<a
  href="/app/artist/{browseId}"
  role="button"
  tabindex={0}
  title={name}
  class="cursor-pointer duration-200 my-0.5 aspect-square rounded-xl gap-2 hover:opacity-50"
>
  <Image
    src={thumbnail}
    alt="Artist Cover"
    {height}
    {width}
    class="rounded-full aspect-square object-cover duration-200"
  />
</a>
