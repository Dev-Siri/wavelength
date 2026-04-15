<script lang="ts">
  import { EllipsisIcon, PlayIcon } from "@lucide/svelte";
  import { toast } from "svelte-sonner";
  import { fly } from "svelte/transition";

  import type { MusicTrack } from "$lib/schemas/music-track";

  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";
  import { reportErrorToBackend } from "$lib/utils/query-client";

  import ArtistLink from "../artist/ArtistLink.svelte";
  import ExplicitIndicator from "../ExplicitIndicator.svelte";
  import Image from "../Image.svelte";
  import PlaylistToggleOptions from "../playlist/PlaylistToggleOptions.svelte";
  import TrackLikeButton from "../track/TrackLikeButton.svelte";
  import { Button, buttonVariants } from "../ui/button";
  import * as ContextMenu from "../ui/context-menu";
  import * as DropdownMenu from "../ui/dropdown-menu";

  const { topResult }: { topResult: MusicTrack } = $props();

  let isHoveringCard = $state(false);

  async function playSong() {
    try {
      musicPlayer.load(
        { ...topResult, videoType: "VIDEO_TYPE_TRACK" },
        {
          type: "none",
        },
      );
    } catch (error) {
      toast.error(`Playback ${error}`);
      await reportErrorToBackend({
        error,
        source: "TopSearchResult: playSong()",
      });
    }
  }
</script>

<ContextMenu.Root>
  <ContextMenu.Trigger>
    <div
      class="relative w-full group bg-muted bg-opacity-40 rounded-2xl h-full p-5 duration-200"
      tabindex={0}
      role="button"
      onclick={playSong}
      onkeydown={e => (e.key === "Enter" || e.key === "Space") && playSong()}
      onmouseenter={() => (isHoveringCard = true)}
      onmouseleave={() => (isHoveringCard = false)}
    >
      <div class="flex justify-center absolute right-5">
        <TrackLikeButton music={topResult} />
        <DropdownMenu.Root>
          <DropdownMenu.Trigger
            onclick={e => e.stopPropagation()}
            class={buttonVariants({ variant: "ghost", size: "sm" })}
          >
            <EllipsisIcon class="text-gray-400" />
          </DropdownMenu.Trigger>
          <DropdownMenu.Content>
            <PlaylistToggleOptions
              music={topResult}
              ui="dropdown"
              videoType="VIDEO_TYPE_TRACK"
              toggle={{ type: "add" }}
            />
          </DropdownMenu.Content>
        </DropdownMenu.Root>
      </div>
      <Image
        src={topResult.thumbnail}
        alt="Top Result Thumbnail"
        height={144}
        width={144}
        class="rounded-lg h-36 w-36"
      />
      <h2
        class="scroll-m-20 pb-2 text-3xl font-semibold tracking-tight leading-none transition-colors {topResult
          .title.length > 30
          ? 'mt-2'
          : 'mt-4'}"
      >
        {topResult.title.length > 65 ? `${topResult.title.slice(0, 65)}...` : topResult.title}
      </h2>
      <div class="flex gap-2 items-center">
        {#if topResult.isExplicit}
          <ExplicitIndicator />
        {/if}
        {#each topResult.artists as artist, i (artist.browseId)}
          <ArtistLink
            {...artist}
            trailingComma={i + 1 !== topResult.artists.length}
            class="text-lg mt-2"
          />
        {/each}
      </div>
      {#if isHoveringCard}
        <div class="right-5 top-[70%] absolute">
          <div in:fly={{ y: 10, x: 0 }}>
            <Button class="rounded-full h-14 w-14">
              <PlayIcon class="text-primary-foreground" fill="black" />
            </Button>
          </div>
        </div>
      {/if}
    </div>
  </ContextMenu.Trigger>
  <ContextMenu.Content>
    <PlaylistToggleOptions
      music={topResult}
      videoType="VIDEO_TYPE_TRACK"
      ui="contextmenu"
      toggle={{ type: "add" }}
    />
  </ContextMenu.Content>
</ContextMenu.Root>
