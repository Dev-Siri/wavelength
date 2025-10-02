<script lang="ts">
  import { EllipsisIcon } from "@lucide/svelte";

  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import musicQueueStore from "$lib/stores/music-queue.svelte";
  import playlistsStore from "$lib/stores/playlists.svelte";
  import { durationify, parseHtmlEntities } from "$lib/utils/format.js";
  import { getStreamUrl, getThumbnailUrl } from "$lib/utils/url";

  import Image from "./Image.svelte";
  import MusicPlayerControls from "./MusicPlayerControls.svelte";
  import PlaybackOptions from "./PlaybackOptions.svelte";
  import PlaylistToggleOptions from "./PlaylistToggleOptions.svelte";
  import * as DropdownMenu from "./ui/dropdown-menu";

  let musicPlayerElement: HTMLAudioElement;

  function handlePlayerEnd() {
    if (musicPlayerStore.musicRepeatMode === "one") return musicPlayerStore.playMusic();

    if (!musicQueueStore.musicPlayingNow) return;

    musicPlayerStore.isMusicPlaying = false;

    const songThatWasPlayedIndex = musicQueueStore.musicQueue.findIndex(
      track => musicQueueStore.musicPlayingNow?.title === track.title,
    );

    const wasSongTheLastInQueue = musicQueueStore.musicQueue.length - 1 === songThatWasPlayedIndex;

    let nextIndex = 0;

    if (wasSongTheLastInQueue) {
      nextIndex = 0;
    } else {
      nextIndex = songThatWasPlayedIndex + 1;
    }

    if (musicPlayerStore.musicRepeatMode === "all" || !wasSongTheLastInQueue)
      musicQueueStore.musicPlayingNow = musicQueueStore.musicQueue[nextIndex];
  }

  $effect(() => {
    musicPlayerStore.musicPlayer = musicPlayerElement;

    function musicPlayerShortcuts(event: KeyboardEvent) {
      if (event.key !== " " || (document.activeElement && document.activeElement !== document.body))
        return;

      if (musicPlayerStore.isMusicPlaying) {
        musicPlayerElement.pause();
      } else {
        musicPlayerElement.play();
      }
    }

    window.addEventListener("keypress", musicPlayerShortcuts);

    return () => window.removeEventListener("keypress", musicPlayerShortcuts);
  });

  $effect(() => {
    async function handleMusicPlayingNowChange() {
      if (!musicQueueStore.musicPlayingNow) return (navigator.mediaSession.metadata = null);

      musicPlayerStore.musicCurrentTime = 0;

      musicPlayerStore.musicSource = getStreamUrl(musicQueueStore.musicPlayingNow.videoId, "audio");
      musicPlayerStore.isMusicPlaying = true;

      if ("mediaSession" in navigator)
        navigator.mediaSession.metadata = new MediaMetadata({
          title: musicQueueStore.musicPlayingNow.title,
          artist: musicQueueStore.musicPlayingNow.author,
          artwork: [
            {
              src: getThumbnailUrl(musicQueueStore.musicPlayingNow.videoId),
              sizes: "256x256",
              type: "image/jpeg",
            },
          ],
        });
    }

    handleMusicPlayingNowChange();
  });
</script>

<div class="flex bg-black h-full w-full pl-3">
  <audio
    autoplay
    bind:this={musicPlayerElement}
    class="hidden"
    src={musicPlayerStore.musicSource}
    bind:muted={musicPlayerStore.isMusicMuted}
    onpause={() => (musicPlayerStore.isMusicPlaying = false)}
    onplay={() => (musicPlayerStore.isMusicPlaying = true)}
    onended={handlePlayerEnd}
    ondurationchange={({ currentTarget: { duration } }) =>
      (musicPlayerStore.musicDuration = duration)}
    ontimeupdate={({ currentTarget: { currentTime } }) =>
      (musicPlayerStore.musicCurrentTime = currentTime)}
    bind:volume={musicPlayerStore.volume}
  ></audio>
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
            {#key musicQueueStore.musicPlayingNow}
              <Image
                src={getThumbnailUrl(musicQueueStore.musicPlayingNow.videoId)}
                alt="Cover"
                height={80}
                width={80}
                class="rounded-md object-cover aspect-square duration-200 group-hover:brightness-75"
              />
            {/key}
          </div>
        </DropdownMenu.Trigger>
        <DropdownMenu.Content class="z-9999" hidden={!playlistsStore.playlists.length}>
          <PlaylistToggleOptions
            music={{
              ...musicQueueStore.musicPlayingNow,
              isExplicit: false,
              duration: durationify(musicPlayerStore.musicDuration),
            }}
          />
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
