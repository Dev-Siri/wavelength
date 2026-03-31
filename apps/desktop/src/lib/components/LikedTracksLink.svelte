<script lang="ts">
  import { resolve } from "$app/paths";
  import { HeartIcon } from "@lucide/svelte";

  import useLikeCountQuery from "$lib/queries/likeCount";

  import Button from "./ui/button/button.svelte";

  const { mode = "full" }: { mode?: "icon" | "full" } = $props();

  const likeCountQuery = useLikeCountQuery();
</script>

<a
  href={resolve("/app/likes")}
  tabindex="0"
  class="flex group cursor-pointer items-center p-2.5 pr-3 hover:bg-[#1c1c1c] my-0.5 rounded-xl w-full gap-2 {mode ===
  'full'
    ? 'justify-start'
    : 'justify-center'}"
>
  <Button variant="outline" class="p-0 h-15 w-15 aspect-square">
    <div class="like-gradient h-full w-full rounded-md grid place-items-center">
      <HeartIcon fill="white" />
    </div>
  </Button>
  {#if mode === "full"}
    <div class="w-full">
      <div class="text-start">
        <p class="text-md font-semibold">Liked Songs</p>
        {#if likeCountQuery.isError}
          <p class="text-xs text-red-500">An error occured.</p>
        {:else if likeCountQuery.isSuccess}
          <p
            class="text-xs text-muted-foreground font-medium bg-secondary py-0.5 px-1 mt-0.5 w-fit"
          >
            {likeCountQuery.data.likeCount === 0 ? "No" : likeCountQuery.data.likeCount}
            {likeCountQuery.data.likeCount === 1 ? "song" : "songs"}
          </p>
        {:else}
          <p class="text-xs text-muted-foreground">Loading...</p>
        {/if}
      </div>
    </div>
  {/if}
</a>
