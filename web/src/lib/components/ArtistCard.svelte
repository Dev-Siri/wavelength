<script lang="ts">
  import type { FollowedArtist } from "$lib/utils/validation/artist-response";

  import Image from "./Image.svelte";

  const { thumbnail, browseId, name }: Pick<FollowedArtist, "thumbnail" | "browseId" | "name"> =
    $props();
</script>

<a
  href="/app/artist/{browseId}"
  role="button"
  tabindex={0}
  title={name}
  class="cursor-pointer duration-200 my-0.5 rounded-xl gap-2 hover:opacity-50"
>
  <Image
    src={thumbnail}
    alt="Artist Cover"
    height={128}
    width={128}
    class="rounded-full h-32 w-32 aspect-square object-cover duration-200"
  />
</a>
