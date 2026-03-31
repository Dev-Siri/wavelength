<script lang="ts">
  import { resolve } from "$app/paths";

  import type { FollowedArtist } from "$lib/schemas/artist";

  import Image from "../Image.svelte";

  const {
    thumbnail,
    browseId,
    audience,
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
    <p class="font-semibold text-xl">{name}</p>
    {#if audience}
      <p class="text-sm text-muted-foreground -mt-2">{audience}</p>
    {/if}
  {/if}
</a>
