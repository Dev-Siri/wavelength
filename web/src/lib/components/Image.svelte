<script lang="ts">
  import { PUBLIC_BACKEND_URL } from "$env/static/public";

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
  src={originalUri ? src : `${PUBLIC_BACKEND_URL}/image?url=${encodeURIComponent(src)}`}
  {alt}
  {height}
  {width}
  {loading}
  class={className}
  {...restProps}
/>
