<script lang="ts">
  import { HeartIcon } from "@lucide/svelte";
  import { createMutation, useQueryClient } from "@tanstack/svelte-query";
  import { toast } from "svelte-sonner";
  import { z } from "zod";

  import type { MusicTrack } from "$lib/schemas/music-track";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import useIsTrackLiked from "$lib/queries/isTrackLiked";
  import { musicTrackDurationSchema } from "$lib/schemas/track-length";
  import { backendClient } from "$lib/utils/query-client";

  import { Button } from "../ui/button";

  const {
    music,
    isPreLiked,
  }: {
    music: MusicTrack;
    /**
     * isPreLiked is a boolean provided to the component to let it know if the track is already liked
     * Providing this avoids the component itself from fetchign it's liked status, which reduces the
     * demand on the server in-case there are 100s or 1000s of tracks on the screen.
     */
    isPreLiked?: boolean;
  } = $props();

  const queryClient = useQueryClient();

  const isTrackLikedQuery = $derived(
    useIsTrackLiked(music.videoId, { enabled: isPreLiked == null }),
  );

  let isLiked = $derived(isPreLiked != null ? isPreLiked : !!isTrackLikedQuery.data?.isLiked);

  const likeMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.likeTrack(music.videoId),
    async mutationFn() {
      let duration = music.duration;

      if (!duration) {
        const fetchedDuration = await backendClient(
          `/music/track/${music.videoId}/duration`,
          musicTrackDurationSchema,
        );
        duration = fetchedDuration.durationSeconds.toString();
      }

      isLiked = !isLiked;
      return backendClient("/music/track/likes", z.string(), {
        method: "PATCH",
        body: {
          ...music,
          duration,
          videoType: "track",
        },
      });
    },
    onError() {
      isLiked = !isLiked;
      toast.error("Like failed.");
    },
    onSuccess() {
      isTrackLikedQuery.refetch();
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.likeCount });
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.likes });
    },
  }));

  function handleLike(
    e:
      | (MouseEvent & { currentTarget: EventTarget & HTMLButtonElement })
      | (MouseEvent & { currentTarget: EventTarget & HTMLAnchorElement }),
  ) {
    e.stopPropagation();
    likeMutation.mutate();
  }

  const likedClasses = $derived(isLiked ? "text-red-500" : "scale-0 group-hover:scale-100");
</script>

<Button
  variant="ghost"
  size="icon"
  class="flex items-center justify-center text-muted-foreground transition-all hover:bg-transparent {likedClasses}"
  onclick={handleLike}
>
  {#if isLiked}
    <HeartIcon fill="red" />
  {:else}
    <HeartIcon />
  {/if}
</Button>
