<script lang="ts">
  import { goto } from "$app/navigation";

  import type { EmbeddedArtist } from "$lib/utils/validation/artist";

  import ArtistPreview from "./ArtistPreview.svelte";
  import Button from "./ui/button/button.svelte";
  import * as Tooltip from "./ui/tooltip";

  const {
    browseId,
    title,
    trailingComma,
    isUVideo,
  }: EmbeddedArtist & {
    trailingComma?: boolean;
    isUVideo?: boolean;
  } = $props();

  const artistPagePath = isUVideo
    ? `https://youtube.com/channel/${browseId}`
    : `/app/artist/${browseId}`;

  function handleNavigation(
    e:
      | (MouseEvent & { currentTarget: EventTarget & HTMLAnchorElement })
      | (MouseEvent & { currentTarget: EventTarget & HTMLButtonElement }),
  ) {
    e.stopPropagation();
    e.preventDefault();

    if (isUVideo) {
      window.open(artistPagePath);
    } else {
      goto(artistPagePath);
    }
  }

  function handlePreviewClick(e: MouseEvent & { currentTarget: EventTarget & HTMLDivElement }) {
    e.stopPropagation();
    e.preventDefault();

    goto(artistPagePath);
  }
</script>

{#if isUVideo}
  <Button
    variant="link"
    target="_blank"
    referrerpolicy="no-referrer"
    class="p-0 m-0 -mt-2 mr-1 text-sm text-muted-foreground"
    href={artistPagePath}
    onclick={handleNavigation}
  >
    {title}
  </Button>
{:else}
  <Tooltip.Root>
    <Tooltip.Trigger>
      <div class="relative inline">
        <Button
          variant="link"
          class="p-0 m-0 -mt-2 mr-1 text-sm text-muted-foreground"
          href={artistPagePath}
          onclick={handleNavigation}
        >
          {title}{trailingComma ? ", " : " "}
        </Button>
      </div>
    </Tooltip.Trigger>
    <Tooltip.Content onclick={handlePreviewClick} class="relative p-0 h-52 aspect-video">
      <ArtistPreview {browseId} />
    </Tooltip.Content>
  </Tooltip.Root>
{/if}
