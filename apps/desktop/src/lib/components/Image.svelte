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

  const imageUrl = $derived(`${BASE_URL}/api/image?url=${encodeURIComponent(src)}`);
</script>

<img src={imageUrl} {alt} {height} {width} {loading} class={className} {...restProps} in:fade />
