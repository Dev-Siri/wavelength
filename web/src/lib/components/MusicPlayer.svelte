<script lang="ts">
  import { onMount } from "svelte";
  import createYouTubePlayer from "youtube-player";

  import { musicPlayerStates } from "$lib/constants/music-player";
  import {
    isMusicMuted,
    isMusicPlaying,
    musicPlayer,
    musicPlayerProgress,
    musicRepeatMode,
    pauseMusic,
    playMusic,
  } from "$lib/stores/music-player";
  import { musicPlayingNow, musicQueue } from "$lib/stores/music-queue";
  import { durationify, parseHtmlEntities } from "$lib/utils/format";

  import { MoreHorizontal } from "lucide-svelte";
  import Image from "./Image.svelte";
  import MusicPlayerControls from "./MusicPlayerControls.svelte";
  import PlaybackOptions from "./PlaybackOptions.svelte";
  import PlaylistToggleOptions from "./PlaylistToggleOptions.svelte";
  import * as DropdownMenu from "./ui/dropdown-menu";

  let musicPlayerElement: HTMLDivElement;

  async function trackProgress() {
    if (!$musicPlayer || !$isMusicPlaying) return;

    const [currentTime, duration] = await Promise.all([
      $musicPlayer.getCurrentTime(),
      $musicPlayer.getDuration(),
    ]);

    if (duration > 0) {
      const progress = (currentTime / duration) * 100;

      $musicPlayerProgress = progress;
    }
  }

  function onStateChange(event: any) {
    const playerState = event.data;

    switch (playerState) {
      case musicPlayerStates.ended:
        if ($musicRepeatMode === "one") {
          playMusic();
          break;
        }

        if (!$musicPlayingNow) break;

        $isMusicPlaying = false;

        const songThatWasPlayedIndex = $musicQueue.findIndex(
          track => $musicPlayingNow.title === track.title,
        );
        const wasSongTheLastInQueue = $musicQueue.length - 1 === songThatWasPlayedIndex;

        let nextIndex = 0;

        if (wasSongTheLastInQueue) {
          nextIndex = 0;
        } else {
          nextIndex = songThatWasPlayedIndex + 1;
        }

        if ($musicRepeatMode === "all" || !wasSongTheLastInQueue)
          musicPlayingNow.set($musicQueue[nextIndex]);
    }
  }

  onMount(() => {
    const youtubePlayer = createYouTubePlayer(musicPlayerElement, {
      playerVars: {
        autoplay: 0,
      },
    });

    musicPlayer.set(youtubePlayer);

    const interval = setInterval(trackProgress, 250);

    youtubePlayer.on("stateChange", onStateChange);

    function musicPlayerShortcuts(event: KeyboardEvent) {
      if (event.key !== " " || (document.activeElement && document.activeElement !== document.body))
        return;

      if ($isMusicPlaying) {
        pauseMusic();
      } else {
        playMusic();
      }
    }

    window.addEventListener("keypress", musicPlayerShortcuts);

    return () => {
      window.removeEventListener("keypress", musicPlayerShortcuts);
      clearInterval(interval);
      youtubePlayer.destroy();
    };
  });

  $: {
    async function handleMusicPlayingNowChange() {
      if (!$musicPlayer || !$musicPlayingNow) return;

      $musicPlayerProgress = 0;

      await $musicPlayer.loadVideoById($musicPlayingNow.videoId);

      $isMusicPlaying = true;
    }

    handleMusicPlayingNowChange();
  }

  $: {
    if ($isMusicMuted) {
      $musicPlayer?.mute();
    } else {
      $musicPlayer?.unMute();
    }
  }
</script>

<div class="flex bg-black h-full w-full pl-3">
  <div class="hidden" bind:this={musicPlayerElement}></div>
  <section class="flex h-full w-1/3 items-center">
    {#if $musicPlayingNow}
      <DropdownMenu.Root>
        <DropdownMenu.Trigger>
          <div class="relative group h-20 w-20">
            <MoreHorizontal
              class="absolute bg-black bg-opacity-80 z-[99999] rounded-full p-0.5 duration-200 top-2 right-2"
              color="white"
              size={20}
            />
            <Image
              src={$musicPlayingNow.thumbnail}
              alt="Cover"
              height={80}
              width={80}
              class="rounded-md object-cover aspect-square duration-200 group-hover:brightness-75"
            />
          </div>
        </DropdownMenu.Trigger>
        <DropdownMenu.Content>
          {#if $musicPlayer}
            {#await $musicPlayer.getDuration() then duration}
              <PlaylistToggleOptions
                music={{
                  ...$musicPlayingNow,
                  isExplicit: false,
                  duration: durationify(duration),
                }}
              />
            {/await}
          {/if}
        </DropdownMenu.Content>
      </DropdownMenu.Root>
      <div>
        <p class="text-md ml-2 text-primary">{parseHtmlEntities($musicPlayingNow.title)}</p>
        <p class="text-xs ml-2 text-muted-foreground">{$musicPlayingNow.author}</p>
      </div>
    {:else}
      <div class="h-20 w-20 bg-primary-foreground rounded-md"></div>
    {/if}
  </section>
  <section class="flex flex-col gap-2 h-full w-1/3">
    <MusicPlayerControls />
  </section>
  <section class="flex items-center justify-end pr-10 h-full gap-1 w-1/3">
    <PlaybackOptions />
  </section>
</div>
