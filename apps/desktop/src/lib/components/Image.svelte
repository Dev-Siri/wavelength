<script lang="ts">
  import { fade } from "svelte/transition";

  import { BASE_URL } from "$lib/constants/utils";

  const {
    src,
    alt,
    height,
    width,
    loading = "lazy",
    class: className = "",
    ...restProps
  }: {
    src: string;
    alt: string;
    height: number;
    width: number;
    loading?: "lazy" | "eager";
    class?: string;
  } & Record<string, unknown> = $props();

  let imageUrl = $state(`${BASE_URL}/api/image?url=${encodeURIComponent(src)}`);
</script>

<img
  src={imageUrl}
  onerror={() => (imageUrl = `${BASE_URL}/api/image/fallback?url=${encodeURIComponent(src)}`)}
  {alt}
  {height}
  {width}
  {loading}
  class={className}
  {...restProps}
  in:fade
/>
