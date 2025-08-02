<script lang="ts">
  import createYouTubePlayer from "youtube-player";

  import { musicPlayerStates } from "$lib/constants/music-player";
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import playlistsStore from "$lib/stores/playlists.svelte";
  import { durationify, parseHtmlEntities } from "$lib/utils/format";

  import { EllipsisIcon } from "@lucide/svelte";
  import Image from "./Image.svelte";
  import MusicPlayerControls from "./MusicPlayerControls.svelte";
  import PlaybackOptions from "./PlaybackOptions.svelte";
  import PlaylistToggleOptions from "./PlaylistToggleOptions.svelte";
  import * as DropdownMenu from "./ui/dropdown-menu";

  let musicPlayerElement: HTMLDivElement;

  async function trackProgress() {
    if (!musicPlayerStore.musicPlayer || !musicPlayerStore.isMusicPlaying) return;

    const [currentTime, duration] = await Promise.all([
      musicPlayerStore.musicPlayer.getCurrentTime(),
      musicPlayerStore.musicPlayer.getDuration(),
    ]);

    if (duration > 0) {
      const progress = (currentTime / duration) * 100;

      musicPlayerStore.musicPlayerProgress = progress;
    }
  }

  function onStateChange(event: any) {
    const playerState = event.data;

    switch (playerState) {
      // Extra handlers to make sure and sync the state with the player
      // In case a non-application event causes the video's state to change.
      case musicPlayerStates.playing:
        musicPlayerStore.isMusicPlaying = true;
        break;
      case musicPlayerStates.paused:
        musicPlayerStore.isMusicPlaying = false;
        break;
      case musicPlayerStates.ended:
        if (musicPlayerStore.musicRepeatMode === "one") {
          musicPlayerStore.playMusic();
          break;
        }

        if (!musicQueueStore.musicPlayingNow) break;

        musicPlayerStore.isMusicPlaying = false;

        const songThatWasPlayedIndex = musicQueueStore.musicQueue.findIndex(
          track => musicQueueStore.musicPlayingNow?.title === track.title,
        );
        const wasSongTheLastInQueue =
          musicQueueStore.musicQueue.length - 1 === songThatWasPlayedIndex;

        let nextIndex = 0;

        if (wasSongTheLastInQueue) {
          nextIndex = 0;
        } else {
          nextIndex = songThatWasPlayedIndex + 1;
        }

        if (musicPlayerStore.musicRepeatMode === "all" || !wasSongTheLastInQueue)
          musicQueueStore.musicPlayingNow = musicQueueStore.musicQueue[nextIndex];
    }
  }

  $effect(() => {
    const youtubePlayer = createYouTubePlayer(musicPlayerElement, {
      playerVars: {
        autoplay: 0,
      },
    });

    musicPlayerStore.musicPlayer = youtubePlayer;

    const interval = setInterval(trackProgress, 250);

    youtubePlayer.on("stateChange", onStateChange);

    function musicPlayerShortcuts(event: KeyboardEvent) {
      if (event.key !== " " || (document.activeElement && document.activeElement !== document.body))
        return;

      if (musicPlayerStore.isMusicPlaying) {
        musicPlayerStore.pauseMusic();
      } else {
        musicPlayerStore.playMusic();
      }
    }

    window.addEventListener("keypress", musicPlayerShortcuts);

    return () => {
      window.removeEventListener("keypress", musicPlayerShortcuts);
      clearInterval(interval);
      youtubePlayer.destroy();
    };
  });

  $effect(() => {
    async function handleMusicPlayingNowChange() {
      if (!musicPlayerStore.musicPlayer || !musicQueueStore.musicPlayingNow) return;

      musicPlayerStore.musicPlayerProgress = 0;

      await musicPlayerStore.musicPlayer.loadVideoById(musicQueueStore.musicPlayingNow.videoId);

      musicPlayerStore.isMusicPlaying = true;
    }

    handleMusicPlayingNowChange();
  });

  $effect(() => {
    if (musicPlayerStore.isMusicMuted) {
      musicPlayerStore.musicPlayer?.mute();
    } else {
      musicPlayerStore.musicPlayer?.unMute();
    }
  });
</script>

<div class="flex bg-black h-full w-full pl-3">
  <div class="hidden" bind:this={musicPlayerElement}></div>
  <section class="flex h-full w-1/3 items-center">
    {#if musicQueueStore.musicPlayingNow}
      <DropdownMenu.Root>
        <DropdownMenu.Trigger>
          <div class="relative group h-20 w-20 cursor-pointer">
            <EllipsisIcon
              class="absolute bg-black bg-opacity-80 z-99999 rounded-full p-0.5 duration-200 top-2 right-2"
              color="white"
              size={20}
            />
            <Image
              src={musicQueueStore.musicPlayingNow.thumbnail}
              alt="Cover"
              height={80}
              width={80}
              class="rounded-md object-cover aspect-square duration-200 group-hover:brightness-75"
            />
          </div>
        </DropdownMenu.Trigger>
        <DropdownMenu.Content class="z-9999" hidden={!playlistsStore.playlists.length}>
          {#if musicPlayerStore.musicPlayer}
            {#await musicPlayerStore.musicPlayer.getDuration() then duration}
              <PlaylistToggleOptions
                music={{
                  ...musicQueueStore.musicPlayingNow,
                  isExplicit: false,
                  duration: durationify(duration),
                }}
              />
            {/await}
          {/if}
        </DropdownMenu.Content>
      </DropdownMenu.Root>
      <div class="hidden sm:block">
        <p class="text-md ml-2 text-primary">
          {parseHtmlEntities(musicQueueStore.musicPlayingNow.title)}
        </p>
        <p class="text-xs ml-2 text-muted-foreground">{musicQueueStore.musicPlayingNow.author}</p>
      </div>
    {:else}
      <div class="h-20 w-20 bg-primary-foreground rounded-md"></div>
    {/if}
  </section>
  <section class="flex flex-col gap-2 h-full w-1/3">
    <MusicPlayerControls />
  </section>
  <section class="flex items-center justify-end pr-10 h-full gap-1 w-1/3 md:pl-[10%]">
    <PlaybackOptions />
  </section>
</div>
