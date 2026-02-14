<script lang="ts">
  import {
    ArrowUpRightIcon,
    CirclePlayIcon,
    MessageSquareIcon,
    ThumbsUpIcon,
    YoutubeIcon,
  } from "@lucide/svelte";
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import { compactify, punctuatify } from "$lib/utils/format.js";
  import { backendClient } from "$lib/utils/query-client.js";
  import { getThumbnailUrl } from "$lib/utils/url";
  import { musicTrackStatsResponseSchema } from "$lib/utils/validation/music-track-stats";

  import { openUrl } from "@tauri-apps/plugin-opener";
  import Image from "../Image.svelte";
  import { Button } from "../ui/button";
  import * as Tooltip from "../ui/tooltip";

  const musicThumbnail = $derived(getThumbnailUrl(musicQueueStore.musicPlayingNow?.videoId ?? ""));

  const musicStatsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.musicStats(musicQueueStore.musicPlayingNow?.videoId ?? ""),
    queryFn: () =>
      backendClient(
        `/music/track/${musicQueueStore.musicPlayingNow?.videoId}/stats`,
        musicTrackStatsResponseSchema,
      ),
  }));

  let coverStyle = $derived(
    musicQueueStore.currentMusicTheme
      ? `box-shadow: 0 0px 70px 10px rgb(${musicQueueStore.currentMusicTheme.r}, ${musicQueueStore.currentMusicTheme.g}, ${musicQueueStore.currentMusicTheme.b});`
      : "",
  );
</script>

{#if musicQueueStore.musicPlayingNow}
  <section
    class="flex flex-col min-[800px]:flex-row justify-center min-[800px]:justify-start text-center min-[800px]:text-start items-center h-3/5 p-9 min-[800px]:p-14 pt-5"
  >
    <div class="flex flex-col gap-2 z-50">
      {#key musicThumbnail}
        <Image
          src={musicThumbnail}
          alt="Thumbnail"
          height={256}
          width={256}
          class="rounded-2xl h-64 w-64 duration-200"
          style={coverStyle}
        />
      {/key}
      {#if musicStatsQuery.isSuccess}
        {@const { musicTrackStats } = musicStatsQuery.data}
        <section>
          <Button
            href="https://youtube.com/watch?v={musicQueueStore.musicPlayingNow.videoId}"
            variant="secondary"
            referrerpolicy="no-referrer"
            target="_blank"
            class="flex justify-between items-center w-full gap-4"
          >
            {#if musicTrackStats.likeCount}
              <div aria-label="Likes">
                <Tooltip.Root>
                  <Tooltip.Content>
                    <p>{musicTrackStats.likeCount} Likes</p>
                  </Tooltip.Content>
                  <Tooltip.Trigger class="flex items-center justify-center gap-1.5 cursor-default">
                    <ThumbsUpIcon />
                    <p class="text-md text-primary">
                      {compactify(Number(musicTrackStats.likeCount))}
                    </p>
                  </Tooltip.Trigger>
                </Tooltip.Root>
              </div>
              <div aria-label="Comments">
                <Tooltip.Root>
                  <Tooltip.Content>
                    <p>{musicTrackStats.commentCount} Comments</p>
                  </Tooltip.Content>
                  <Tooltip.Trigger class="flex items-center justify-center gap-1.5 cursor-default">
                    <MessageSquareIcon />
                    <p class="text-md text-primary">
                      {compactify(Number(musicTrackStats.commentCount))}
                    </p>
                  </Tooltip.Trigger>
                </Tooltip.Root>
              </div>
              <div aria-label="Streams">
                <Tooltip.Root>
                  <Tooltip.Content>
                    <p>{musicTrackStats.viewCount} Streams</p>
                  </Tooltip.Content>
                  <Tooltip.Trigger class="flex items-center justify-center gap-1.5 cursor-default">
                    <CirclePlayIcon />
                    <p class="text-md text-primary">
                      {compactify(Number(musicTrackStats.viewCount))}
                    </p>
                  </Tooltip.Trigger>
                </Tooltip.Root>
              </div>
            {/if}
          </Button>
        </section>
      {/if}
    </div>
    <div class="min-[800px]:ml-16 mt-4 min-[800px]:mt-0 pt-2">
      <h1
        class="scroll-m-20 pb-2 {musicQueueStore.musicPlayingNow.title.length >= 30
          ? 'text-4xl'
          : 'text-6xl'} font-semibold tracking-tight transition-colors first:mt-0 text-balance w-full"
      >
        {musicQueueStore.musicPlayingNow.title}
      </h1>
      <p class="text-muted-foreground text-2xl ml-1">
        {punctuatify(musicQueueStore.musicPlayingNow.artists.map(artist => artist.title))}
      </p>
      <div class="flex items-center mt-4 lg:mt-24 gap-2 justify-center w-fit flex-col lg:flex-row">
        <Button
          class="px-4 gap-2 text-muted-foreground hidden min-[800px]:flex"
          onclick={() =>
            openUrl(`https://youtube.com/watch?v=${musicQueueStore.musicPlayingNow?.videoId}`)}
          href="https://youtube.com/watch?v={musicQueueStore.musicPlayingNow.videoId}"
          variant="secondary"
          referrerpolicy="no-referrer"
          target="_blank"
        >
          <YoutubeIcon class="text-red-500 stroke-1" size={35} />
          Open on YouTube
          <ArrowUpRightIcon />
        </Button>
        <Button
          class="px-2 gap-2 text-muted-foreground"
          onclick={() =>
            openUrl(
              `https://music.youtube.com/watch?v=${musicQueueStore.musicPlayingNow?.videoId}`,
            )}
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
{/if}
