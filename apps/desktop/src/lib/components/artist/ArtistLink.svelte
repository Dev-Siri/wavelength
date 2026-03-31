<script lang="ts">
  import { goto } from "$app/navigation";
  import { resolve } from "$app/paths";

  import type { EmbeddedArtist } from "$lib/schemas/embedded";

  import cn from "$lib/utils/cn";
  import { openUrl } from "@tauri-apps/plugin-opener";

  import Button from "../ui/button/button.svelte";
  import * as HoverCard from "../ui/hover-card";
  import ArtistPreview from "./ArtistPreview.svelte";

  const {
    browseId,
    title,
    trailingComma,
    isUVideo,
    class: className,
  }: EmbeddedArtist & {
    trailingComma?: boolean;
    isUVideo?: boolean;
    class?: string;
  } = $props();

  const artistPagePath = $derived(
    isUVideo ? `https://youtube.com/channel/${browseId}` : `/app/artist/${browseId}`,
  );

  type AppArtistPath = `/app/artist/${string}`;

  const isMultiArtist = $derived(browseId === "VARIOUS_ARTISTS");

  function handleNavigation(
    e:
      | (MouseEvent & { currentTarget: EventTarget & HTMLAnchorElement })
      | (MouseEvent & { currentTarget: EventTarget & HTMLButtonElement }),
  ) {
    e.stopPropagation();
    e.preventDefault();

    if (isMultiArtist) return;
    if (isUVideo) {
      openUrl(artistPagePath);
    } else {
      goto(resolve(artistPagePath as AppArtistPath));
    }
  }

  function handlePreviewClick(e: MouseEvent & { currentTarget: EventTarget & HTMLDivElement }) {
    e.stopPropagation();
    e.preventDefault();

    if (isMultiArtist) return;
    goto(resolve(artistPagePath as AppArtistPath));
  }
</script>

{#if isUVideo}
  <Button
    variant="link"
    target="_blank"
    referrerpolicy="no-referrer"
    class={cn("p-0 m-0 -mt-2 mr-1 text-xs text-muted-foreground", className)}
    href={isMultiArtist ? null : artistPagePath}
    onclick={handleNavigation}
  >
    {title}
  </Button>
{:else}
  <HoverCard.Root>
    <HoverCard.Trigger>
      <div class="relative inline">
        <Button
          variant="link"
          class={cn(
            "p-0 m-0 h-4 mr-1 text-xs text-muted-foreground",
            isMultiArtist ? "cursor-default" : "cursor-pointer",
            className,
          )}
          href={isMultiArtist ? null : artistPagePath}
          onclick={handleNavigation}
        >
          {title}{trailingComma ? ", " : " "}
        </Button>
      </div>
    </HoverCard.Trigger>
    {#if !isMultiArtist}
      <HoverCard.Content
        onclick={handlePreviewClick}
        class="bg-secondary relative p-0 h-52 z-99999 aspect-video"
      >
        <ArtistPreview {browseId} />
      </HoverCard.Content>
    {/if}
  </HoverCard.Root>
{/if}
