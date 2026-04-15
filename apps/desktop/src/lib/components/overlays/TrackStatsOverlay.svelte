<script lang="ts">
  import { CirclePlayIcon, HeartIcon } from "@lucide/svelte";

  import useMusicTrackStatsQuery from "$lib/queries/musicStats";
  import { musicPlayer } from "$lib/stream-player/audio/musicPlayer";
  import { compactify } from "$lib/utils/format";

  import HifiBadge from "../HifiBadge.svelte";

  const musicTrackStatsQuery = $derived(
    useMusicTrackStatsQuery(musicPlayer.queue.playingNow?.videoId ?? ""),
  );
</script>

{#if musicTrackStatsQuery.isSuccess}
  {@const { viewCount, likeCount } = musicTrackStatsQuery.data.musicTrackStats}
  <div class="flex items-center justify-between w-1/2 mt-4 select-none">
    <div class="flex justify-center gap-2 items-center">
      <HeartIcon class="text-white" fill="white" size={20} />
      <p class="text-xs text-gray-300 font-semibold">{compactify(likeCount, "shortened")}</p>
    </div>
    <HifiBadge />
    <div class="flex justify-center gap-2 items-center">
      <CirclePlayIcon size={20} />
      <p class="text-xs text-gray-300 font-semibold">{compactify(viewCount, "suffixed")}</p>
    </div>
  </div>
{/if}
