<script lang="ts">
  import { resolve } from "$app/paths";

  import type { FollowedArtist } from "$lib/schemas/artist";

  import Image from "../Image.svelte";

  const { thumbnail, browseId, name }: Pick<FollowedArtist, "thumbnail" | "browseId" | "name"> =
    $props();
</script>

<a
  href={resolve(`/app/artist/${browseId}`)}
  role="button"
  tabindex={0}
  class="flex group cursor-pointer items-center justify-start p-2.5 pr-3 bg-[#111] hover:bg-[#1c1c1c] duration-200 my-0.5 rounded-xl w-full gap-2"
>
  <Image
    src={thumbnail}
    alt="Artist Cover"
    height={80}
    width={80}
    class="rounded-full h-15 w-15 aspect-square object-cover group-hover:opacity-50 duration-200"
  />
  <div class="text-start">
    <p class="text-md font-semibold">{name}</p>
    <p class="text-xs text-muted-foreground font-medium bg-secondary py-0.5 px-1 mt-0.5 w-fit">
      Artist
    </p>
  </div>
</a>
