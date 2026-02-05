<script lang="ts">
  import { HeartIcon } from "@lucide/svelte";
  import { createMutation, createQuery, useQueryClient } from "@tanstack/svelte-query";
  import toast from "svelte-french-toast";
  import { z } from "zod";

  import type { MusicTrack } from "$lib/utils/validation/music-track";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";
  import { musicTrackDurationSchema } from "$lib/utils/validation/track-length";

  import { Button } from "../ui/button";

  const { music }: { music: MusicTrack } = $props();

  const queryClient = useQueryClient();

  const isTrackLikedQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.isTrackLiked(music.videoId),
    queryFn: () =>
      backendClient(
        `/music/track/likes/${music.videoId}/is-liked`,
        z.object({ isLiked: z.boolean() }),
      ),
  }));

  const likeMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.likeTrack(music.videoId),
    async mutationFn() {
      let duration = music.duration;

      if (duration === "") {
        const fetchedDuration = await backendClient(
          `/music/track/${music.videoId}/duration`,
          musicTrackDurationSchema,
        );
        duration = fetchedDuration.durationSeconds.toString();
      }

      return backendClient("/music/track/likes", z.string(), {
        method: "PATCH",
        body: {
          ...music,
          duration,
          videoType: "track",
        },
      });
    },
    onError: () => toast.error("Failed to like track."),
    onSuccess() {
      isTrackLikedQuery.refetch();
      queryClient.invalidateQueries({
        queryKey: [...svelteQueryKeys.likeCount, ...svelteQueryKeys.likes],
      });
    },
  }));
</script>

<Button
  variant="ghost"
  class="flex items-center p-0 mx-4 justify-center text-muted-foreground {isTrackLikedQuery.data
    ?.isLiked
    ? 'text-red-500'
    : ''}"
  onclick={() => likeMutation.mutate()}
>
  {#if isTrackLikedQuery.data?.isLiked}
    <HeartIcon fill="red" />
  {:else}
    <HeartIcon />
  {/if}
</Button>
