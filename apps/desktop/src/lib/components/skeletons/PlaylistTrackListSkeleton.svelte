<script>
  import { ClockIcon, HashIcon } from "@lucide/svelte";

  import TrackSkeleton from "./TrackSkeleton.svelte";
</script>

<div class="h-fit" id="playlist-track-list-skeleton">
  <header class="flex items-center select-none text-muted-foreground">
    <section class="flex items-center gap-10 w-1/3">
      <span class="cursor-pointer p-1.5 rounded-full duration-200">
        <HashIcon size={14} />
      </span>
      <p class="text-sm">Title</p>
    </section>
    <section class="flex justify-center w-1/3">
      <p class="text-sm">Album</p>
    </section>
    <section class="flex justify-center w-1/3">
      <ClockIcon size={14} class="mr-6" />
    </section>
  </header>
  <div class="bg-secondary h-[1px] w-full my-2.5 rounded-full"></div>
  {#each new Array(15)}
    <TrackSkeleton />
  {/each}
</div>
