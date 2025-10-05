<script lang="ts">
  import {
    ArrowUpRightIcon,
    CirclePlayIcon,
    MessageSquareIcon,
    ThumbsUpIcon,
    YoutubeIcon,
  } from "@lucide/svelte";

  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { compactify, parseHtmlEntities } from "$lib/utils/format.js";
  import { backendClient } from "$lib/utils/query-client.js";
  import { getThumbnailUrl } from "$lib/utils/url";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { musicTrackStatsSchema } from "$lib/utils/validation/music-track-stats";
  import { themeColorSchema } from "$lib/utils/validation/theme-color";
  import { createQuery } from "@tanstack/svelte-query";
  import Image from "./Image.svelte";
  import { Button } from "./ui/button";
  import * as Tooltip from "./ui/tooltip";

  let musicThumbnail = $derived(getThumbnailUrl(musicQueueStore.musicPlayingNow?.videoId ?? ""));

  const themeColorQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.themeColor(musicThumbnail),
    queryFn: () =>
      backendClient("/image/theme-color", themeColorSchema, {
        searchParams: { imageUrl: musicThumbnail },
      }),
  }));

  const musicStatsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.musicStats(musicQueueStore.musicPlayingNow?.videoId ?? ""),
    queryFn: () =>
      backendClient(
        `/music/track/${musicQueueStore.musicPlayingNow?.videoId}/stats`,
        musicTrackStatsSchema,
        { searchParams: { imageUrl: musicThumbnail } },
      ),
  }));

  let coverStyle = $derived(
    themeColorQuery.isSuccess
      ? `box-shadow: 0 0px 70px 10px rgb(${themeColorQuery.data.r}, ${themeColorQuery.data.g}, ${themeColorQuery.data.b});`
      : "",
  );
</script>

{#if musicQueueStore.musicPlayingNow}
  <section
    class="flex flex-col min-[800px]:flex-row justify-center min-[800px]:justify-start text-center min-[800px]:text-start items-center h-3/5 p-9 min-[800px]:p-14 pt-5"
  >
    <Image
      src={musicThumbnail}
      alt="Thumbnail"
      height={256}
      width={256}
      class="rounded-2xl h-64 w-64 duration-200"
      style={coverStyle}
    />
    <div class="min-[800px]:ml-16 mt-4 min-[800px]:mt-0 pt-2">
      <h1
        class="scroll-m-20 pb-2 {musicQueueStore.musicPlayingNow.title.length >= 30
          ? 'text-4xl'
          : 'text-6xl'} font-semibold tracking-tight transition-colors first:mt-0 text-balance w-full"
      >
        {parseHtmlEntities(musicQueueStore.musicPlayingNow.title)}
      </h1>
      <p class="text-muted-foreground text-2xl ml-1">
        {musicQueueStore.musicPlayingNow.author}
      </p>
      <div class="flex items-center mt-4 lg:mt-24 gap-2 justify-center w-fit flex-col lg:flex-row">
        <Button
          class="px-4 gap-2 text-muted-foreground hidden min-[800px]:flex"
          href="https://youtube.com/watch?v={musicQueueStore.musicPlayingNow.videoId}"
          variant="secondary"
          referrerpolicy="no-referrer"
          target="_blank"
        >
          <YoutubeIcon class="text-red-500 stroke-1" size={35} /> Open on YouTube <ArrowUpRightIcon
          />
        </Button>
        <Button
          class="px-2 gap-2 text-muted-foreground"
          href="https://music.youtube.com/watch?v={musicQueueStore.musicPlayingNow.videoId}"
          variant="secondary"
          referrerpolicy="no-referrer"
          target="_blank"
        >
          <CirclePlayIcon class="text-red-500 stroke-1" size={29} />
          Open on YouTube Music
          <ArrowUpRightIcon />
        </Button>
      </div>
    </div>
  </section>
  {#if musicStatsQuery.isSuccess}
    {@const musicStats = musicStatsQuery.data}
    <section>
      <Button
        href="https://youtube.com/watch?v={musicQueueStore.musicPlayingNow.videoId}"
        variant="secondary"
        referrerpolicy="no-referrer"
        target="_blank"
        class="flex justify-between items-center min-[800px]:ml-14 w-fit gap-4 py-6 min-[800px]:-mt-32 lg:-mt-10"
      >
        {#if musicStats.likeCount}
          <div class="flex items-center justify-center gap-1.5 cursor-default" aria-label="Likes">
            <Tooltip.Root>
              <Tooltip.Trigger>
                <ThumbsUpIcon />
              </Tooltip.Trigger>
              <Tooltip.Content>
                <p>{musicStats.likeCount} Likes</p>
              </Tooltip.Content>
            </Tooltip.Root>
            <p class="text-md text-primary">
              {compactify(Number(musicStats.likeCount))}
            </p>
          </div>
          <div
            class="flex items-center justify-center gap-1.5 cursor-default"
            aria-label="Comments"
          >
            <Tooltip.Root>
              <Tooltip.Trigger>
                <MessageSquareIcon />
              </Tooltip.Trigger>
              <Tooltip.Content>
                <p>{musicStats.commentCount} Comments</p>
              </Tooltip.Content>
            </Tooltip.Root>
            <p class="text-md text-primary">
              {compactify(Number(musicStats.commentCount))}
            </p>
          </div>
          <div class="flex items-center justify-center gap-1.5 cursor-default" aria-label="Streams">
            <Tooltip.Root>
              <Tooltip.Trigger>
                <CirclePlayIcon />
              </Tooltip.Trigger>
              <Tooltip.Content>
                <p>{musicStats.viewCount} Streams</p>
              </Tooltip.Content>
            </Tooltip.Root>
            <p class="text-md text-primary">
              {compactify(Number(musicStats.viewCount))}
            </p>
          </div>
        {/if}
      </Button>
    </section>
  {/if}
{/if}
