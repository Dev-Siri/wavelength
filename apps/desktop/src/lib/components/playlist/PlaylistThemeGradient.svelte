<script lang="ts">
  import { blur } from "svelte/transition";

  import useThemeColorQuery from "$lib/queries/themeColor";

  const {
    playlistCover,
    extraSpread,
  }: {
    playlistCover: string;
    extraSpread?: boolean;
  } = $props();

  const playlistThemeColorQuery = $derived(useThemeColorQuery(playlistCover));
</script>

{#if playlistThemeColorQuery.data}
  <div
    in:blur
    out:blur
    class="absolute duration-200 h-1/4 inset-0 pointer-events-none"
    style="
        background: linear-gradient(to bottom, rgb({playlistThemeColorQuery.data
      .r}, {playlistThemeColorQuery.data.g}, {playlistThemeColorQuery.data
      .b}), transparent {extraSpread ? '' : ', transparent, transparent'});
        opacity: {extraSpread ? 0.3 : 0.5};
      "
  ></div>
{/if}
