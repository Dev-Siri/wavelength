<script lang="ts">
  import { ArrowUpRight, MessageSquare, PlayCircle, ThumbsUp, Youtube } from "lucide-svelte";
  import { onMount } from "svelte";

  import type { ApiResponse } from "$lib/utils/types";
  import type { youtube_v3 } from "googleapis";

  import { musicPlayingNow } from "$lib/stores/music-queue";
  import { compactify, parseHtmlEntities } from "$lib/utils/format";
  import queryClient from "$lib/utils/query-client";

  import Image from "./Image.svelte";
  import { Button } from "./ui/button";
  import * as Tooltip from "./ui/tooltip";

  let themeColor = "";
  let videoStats: youtube_v3.Schema$VideoStatistics | null = null;

  $: coverStyle = themeColor ? `box-shadow: 0 0px 70px 10px ${themeColor};` : "";

  onMount(async () => {
    if ($musicPlayingNow) {
      const [themeColorResponse, statsResponse] = await Promise.all([
        queryClient<ApiResponse<string>>(
          location.toString(),
          `/api/music/${$musicPlayingNow.videoId}/theme-color`,
        ),
        queryClient<ApiResponse<youtube_v3.Schema$VideoStatistics>>(
          location.toString(),
          `/api/music/${$musicPlayingNow.videoId}/stats`,
        ),
      ]);

      if (themeColorResponse.success) themeColor = themeColorResponse.data;

      if (statsResponse.success) videoStats = statsResponse.data;
    }
  });
</script>

{#if $musicPlayingNow}
  <section class="flex h-3/5 p-14 pt-5">
    <Image
      src={`/api/music/${$musicPlayingNow.videoId}/thumbnail`}
      alt="Thumbnail"
      height={256}
      width={256}
      class="rounded-2xl h-64 w-64 duration-200"
      style={coverStyle}
    />
    <div class="ml-16 pt-2">
      <h1
        class="scroll-m-20 pb-2 {$musicPlayingNow.title.length >= 30
          ? 'text-4xl'
          : 'text-6xl'} font-semibold tracking-tight transition-colors first:mt-0 text-balance w-full"
      >
        {parseHtmlEntities($musicPlayingNow.title)}
      </h1>
      <p class="text-muted-foreground text-2xl ml-1">
        {$musicPlayingNow.author}
      </p>
      <div class="flex items-center mt-4 lg:mt-24 gap-2 justify-center w-fit flex-col lg:flex-row">
        <Button
          class="px-2 gap-2 text-muted-foreground"
          href="https://youtube.com/watch?v={$musicPlayingNow.videoId}"
          variant="secondary"
          referrerpolicy="no-referrer"
          target="_blank"
        >
          <Youtube class="text-red-500 stroke-1" size={35} /> Open on YouTube <ArrowUpRight />
        </Button>
        <Button
          class="px-2 gap-2 text-muted-foreground"
          href="https://music.youtube.com/watch?v={$musicPlayingNow.videoId}"
          variant="secondary"
          referrerpolicy="no-referrer"
          target="_blank"
        >
          <PlayCircle class="text-red-500 stroke-1" size={29} />
          Open on YouTube Music
          <ArrowUpRight />
        </Button>
      </div>
    </div>
  </section>
  {#if videoStats}
    <section>
      <Button
        href="https://youtube.com/watch?v={$musicPlayingNow.videoId}"
        variant="secondary"
        referrerpolicy="no-referrer"
        target="_blank"
        class="flex justify-between items-center ml-14 w-fit gap-4 py-6 -mt-32 lg:-mt-10"
      >
        {#if videoStats.likeCount}
          <div class="flex items-center justify-center gap-1.5 cursor-default" aria-label="Likes">
            <Tooltip.Root>
              <Tooltip.Trigger>
                <ThumbsUp />
              </Tooltip.Trigger>
              <Tooltip.Content>
                <p>{videoStats.likeCount} Likes</p>
              </Tooltip.Content>
            </Tooltip.Root>
            <p class="text-md text-primary">
              {compactify(Number(videoStats.likeCount))}
            </p>
          </div>
          <div
            class="flex items-center justify-center gap-1.5 cursor-default"
            aria-label="Comments"
          >
            <Tooltip.Root>
              <Tooltip.Trigger>
                <MessageSquare />
              </Tooltip.Trigger>
              <Tooltip.Content>
                <p>{videoStats.commentCount} Comments</p>
              </Tooltip.Content>
            </Tooltip.Root>
            <p class="text-md text-primary">
              {compactify(Number(videoStats.commentCount))}
            </p>
          </div>
          <div class="flex items-center justify-center gap-1.5 cursor-default" aria-label="Streams">
            <Tooltip.Root>
              <Tooltip.Trigger>
                <PlayCircle />
              </Tooltip.Trigger>
              <Tooltip.Content>
                <p>{videoStats.viewCount} Streams</p>
              </Tooltip.Content>
            </Tooltip.Root>
            <p class="text-md text-primary">
              {compactify(Number(videoStats.viewCount))}
            </p>
          </div>
        {/if}
      </Button>
    </section>
  {/if}
{/if}
