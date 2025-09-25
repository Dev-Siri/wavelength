<script lang="ts">
  import { BASE_URL } from "$lib/constants/urls.js";

  const {
    src,
    alt,
    height,
    width,
    loading = "lazy",
    originalUri = false,
    class: className = "",
    ...restProps
  }: {
    src: string;
    alt: string;
    height: number;
    width: number;
    loading?: "lazy" | "eager";
    originalUri?: boolean;
    class?: string;
  } & Record<string, any> = $props();
</script>

<img
  src={originalUri ? src : `${BASE_URL}/api/image?url=${encodeURIComponent(src)}`}
  {alt}
  {height}
  {width}
  {loading}
  class={className}
  {...restProps}
/>
