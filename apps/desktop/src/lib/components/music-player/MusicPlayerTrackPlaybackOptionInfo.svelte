<script lang="ts">
  import { InfoIcon } from "@lucide/svelte";

  import settingsStore from "$lib/stores/settings.svelte";
  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";
  import { compactify } from "$lib/utils/format";

  import { buttonVariants } from "../ui/button";
  import * as HoverCard from "../ui/hover-card";

  function getReadableCodec(codec: string) {
    if (codec === "aac") return " (AAC)";
    if (codec === "flac") return "";
    return ` (${codec.charAt(0).toUpperCase()}${codec.slice(1)})`;
  }

  function getReadableBitrate({
    bitrate,
    ext,
    sampleRate,
  }: {
    bitrate: number;
    ext: string;
    sampleRate: number;
  }) {
    if (bitrate === 1_520_000) {
      const formattedRate = (sampleRate / 1000).toFixed(1).replace(".0", "");
      return `1,520kb/s • 24-bit • ${formattedRate}kHz\nHi-Fi Lossless (FLAC)`;
    }
    if (bitrate === 1_411_000) return `1,411kb/s • 16-bit • 44.1kHz\nHi-Fi Lossless (FLAC)`;
    if (bitrate === 128) return `128kb/s (${ext.toUpperCase()})`;
    if (bitrate === 320_000) return `320kb/s • 44.1kHz\nHi-Fi (${ext.toUpperCase()})`;
    if (bitrate === 256_000) return `256kb/s • 44.1kHz\nHigh Quality (${ext.toUpperCase()})`;
    return `${compactify(bitrate)}kb/s (${ext.toUpperCase()})`;
  }
</script>

{#if settingsStore.settings.showStats}
  <HoverCard.Root>
    <HoverCard.Trigger
      class={buttonVariants({
        variant: "ghost",
        class: `w-fit px-3 rounded-full ${musicPlayer.currentStream?.metadata ? "" : "opacity-50 cursor-default hover:bg-transparent"}`,
      })}
    >
      <InfoIcon
        size={20}
        class="text-primary {musicPlayer.currentStream?.metadata ? '' : 'opacity-50'}"
      />
    </HoverCard.Trigger>
    <HoverCard.Content class="z-9999 w-full {musicPlayer.currentStream?.metadata ? '' : 'hidden'}">
      {#if musicPlayer.currentStream?.metadata}
        {@const {
          metadata: { bitrate, codec, ext },
          source: { sampleRate, name },
        } = musicPlayer.currentStream}
        <span class="text-xl mb-2 font-semibold select-none">Stream</span>
        <p>
          <code class="whitespace-pre-line">
            {getReadableBitrate({ bitrate, ext, sampleRate })}{getReadableCodec(codec)}
          </code>
        </p>
        <p>
          <code class="whitespace-pre-line">from {name}</code>
        </p>
      {/if}
    </HoverCard.Content>
  </HoverCard.Root>
{/if}
