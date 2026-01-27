<script lang="ts">
  import { CheckIcon, UserIcon } from "@lucide/svelte";
  import { createMutation, createQuery, useQueryClient } from "@tanstack/svelte-query";
  import { toast } from "svelte-french-toast";
  import { scale } from "svelte/transition";
  import { z } from "zod";

  import type { EmbeddedArtist } from "$lib/utils/validation/artist";

  import { svelteMutationKeys, svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";

  import { Button } from "$lib/components/ui/button";

  const { thumbnail, title, browseId }: EmbeddedArtist & { thumbnail: string } = $props();

  const queryClient = useQueryClient();

  const isFollowingQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.isFollowingArtist(browseId),
    queryFn: () =>
      backendClient(
        `/artists/followed/${browseId}/is-following`,
        z.object({ isFollowing: z.boolean() }),
      ),
  }));

  let isFollowing = $derived(isFollowingQuery.data?.isFollowing);

  const followArtistMutation = createMutation(() => ({
    mutationKey: svelteMutationKeys.followArtist(browseId),
    mutationFn: () =>
      backendClient("/artists/followed", z.string(), {
        method: "POST",
        body: {
          name: title,
          browseId,
          thumbnail,
        },
      }),
    onSuccess: () => {
      isFollowing = !isFollowing;
      isFollowingQuery.refetch();
      queryClient.invalidateQueries({ queryKey: svelteQueryKeys.followedArtists });
    },
    onError: () => toast.error(`Failed to ${isFollowing ? "unfollow" : "follow"} artist.`),
  }));
</script>

<Button variant={isFollowing ? "outline" : "default"} onclick={() => followArtistMutation.mutate()}>
  {#if isFollowing}
    <div in:scale>
      <CheckIcon />
    </div>
  {:else}
    <div in:scale>
      <UserIcon />
    </div>
  {/if}
  {#if isFollowing}
    Following
  {:else}
    Follow
  {/if}
</Button>
