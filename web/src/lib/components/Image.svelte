<script lang="ts">
  import { BASE_URL } from "$lib/constants/urls.js";

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
  } & Record<string, any> = $props();

  let imageUrl = $state(`${BASE_URL}/api/image?url=${encodeURIComponent(src)}`);
</script>

<img
  src={imageUrl}
  onerror={() => (imageUrl = src)}
  {alt}
  {height}
  {width}
  {loading}
  class={className}
  {...restProps}
/>
