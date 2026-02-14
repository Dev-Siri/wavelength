<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";
  import { themeColorSchema } from "$lib/utils/validation/theme-color";

  const { playlistCover }: { playlistCover: string } = $props();

  const playlistThemeColorQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.themeColor(playlistCover),
    queryFn() {
      if (!playlistCover) return { r: 0, g: 0, b: 0 };

      return backendClient(`/image/theme-color`, themeColorSchema, {
        searchParams: { imageUrl: playlistCover },
      });
    },
  }));
</script>

{#if playlistThemeColorQuery.isSuccess}
  <div
    class="absolute duration-200 h-1/2 z-0 inset-0 pointer-events-none"
    style="
        background: linear-gradient(to bottom, rgb({playlistThemeColorQuery.data
      .r}, {playlistThemeColorQuery.data.g}, {playlistThemeColorQuery.data.b}), transparent);
        opacity: 0.5;
      "
  ></div>
{/if}
