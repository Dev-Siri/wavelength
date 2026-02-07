<script lang="ts">
  import { PlayIcon } from "@lucide/svelte";

  import Image from "../Image.svelte";

  const { thumbnail }: { thumbnail: string } = $props();
</script>

<div
  class="flex flex-col aspect-square items-center justify-center relative h-14 w-14 duration-200"
>
  <PlayIcon class="absolute hidden group-hover:block z-50" size={18} fill="white" />
  {#key thumbnail}
    <Image
      src={thumbnail}
      alt="Thumbnail"
      class="rounded-xl aspect-square object-cover h-full w-full group-hover:opacity-40"
      height={64}
      width={70}
    />
  {/key}
</div>
