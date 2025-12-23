<script lang="ts">
  import { HeartIcon } from "@lucide/svelte";
  import { createQuery } from "@tanstack/svelte-query";
  import { z } from "zod";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";

  import Button from "./ui/button/button.svelte";

  const likeTracksCountQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.likeCount,
    queryFn: () => backendClient("/music/track/likes/count", z.number()),
  }));
</script>

<a
  href="/app/likes"
  tabindex="0"
  class="flex group cursor-pointer items-center justify-start p-2.5 pr-3 bg-[#111] hover:bg-[#1c1c1c] my-0.5 rounded-xl w-full gap-2"
>
  <Button variant="outline" class="p-0 h-15 w-15 aspect-square">
    <div class="like-gradient h-full w-full rounded-md grid place-items-center">
      <HeartIcon fill="white" />
    </div>
  </Button>
  <div class="w-full">
    <div class="text-start">
      <p class="text-md">Likes</p>
      {#if likeTracksCountQuery.isError}
        <p class="text-xs text-red-500">An error occured.</p>
      {:else if likeTracksCountQuery.isSuccess}
        <p class="text-xs text-muted-foreground">
          {likeTracksCountQuery.data === 0 ? "No" : likeTracksCountQuery.data}
          {likeTracksCountQuery.data === 1 ? "song" : "songs"}
        </p>
      {:else}
        <p class="text-xs text-muted-foreground">Loading...</p>
      {/if}
    </div>
  </div>
</a>
