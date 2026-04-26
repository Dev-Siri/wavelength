<script lang="ts">
  import { fade } from "svelte/transition";

  import { googleCast } from "../googleCast.svelte";

  import MusicPlayerControls from "./MusicPlayerControls.svelte";
  import ReceiverHeader from "./ReceiverHeader.svelte";
</script>

{#if googleCast.track}
  <div
    in:fade
    id="wavlen-streaming-client"
    class="flex flex-col items-between h-full"
  >
    <cast-media-player></cast-media-player>
    <div class="h-3/4 w-full flex">
      <section class="h-full w-1/2 flex flex-col">
        <ReceiverHeader />
        <div class="flex flex-col h-full gap-2 justify-center">
          <p
            class="text-base ml-0.5 tracking-wide font-medium text-muted-foreground uppercase"
          >
            {googleCast.track.albumName}
          </p>
          <h1 class="text-5xl">{googleCast.track.title}</h1>
          <p class="text-xl ml-0.5 text-muted-foreground">
            {googleCast.track.artist}
          </p>
          <p class="text-sm ml-1 text-muted-foreground">Lossless</p>
        </div>
      </section>
      <section class="h-full w-1/2 flex flex-col items-center justify-center">
        <img
          src="https://i.scdn.co/image/ab67616d0000b2738ad8f5243d6534e03b656c8b"
          alt="Album Cover of 'Starboy (feat. Daft Punk)'"
          height="400"
          width="400"
          class="rounded-2xl w-5/6 aspect-square"
        />
      </section>
    </div>
    <div class="flex flex-col h-1/4 justify-center">
      <MusicPlayerControls />
    </div>
  </div>
{/if}
