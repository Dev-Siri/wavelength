<script lang="ts">
  import Image from "./Image.svelte";

  const { thumbnails }: { thumbnails: string[] } = $props();

  const gridDimensions = $derived.by(() => {
    if (thumbnails.length === 1) return "";
    if (thumbnails.length === 2) return "grid-cols-2 grid-rows-1";
    return "grid-cols-2 grid-rows-2";
  });

  const gridThumbnails = $derived.by(() => {
    if (thumbnails.length === 3) return thumbnails.slice(0, 2);
    return thumbnails;
  });
</script>

<div
  class="grid h-60 w-60 place-items-center bg-black rounded-sm aspect-square overflow-hidden {gridDimensions}"
>
  {#each gridThumbnails as thumbnail, i (thumbnail)}
    <Image
      src={thumbnail}
      alt="Playlist Cover Part {i + 1}"
      class="h-full w-full object-cover"
      height={240}
      width={240}
    />
  {/each}
  {#if thumbnails.length === 3}
    <Image
      src={thumbnails[2]}
      alt="Playlist Cover Part 3"
      class="object-cover h-full w-full col-span-2"
      height={240}
      width={240}
    />
  {/if}
</div>
