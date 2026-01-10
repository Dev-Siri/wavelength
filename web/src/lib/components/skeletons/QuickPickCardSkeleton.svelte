<script lang="ts">
  import Skeleton from "../ui/skeleton/skeleton.svelte";
</script>

<div
  role="presentation"
  class="h-24 flex py-2 items-center duration-200 bg-[#1c1c1c] rounded-2xl cursor-pointer group"
>
  <div class="h-24 w-24 aspect-square p-2 relative rounded-2xl">
    <Skeleton class="h-full w-full rounded-2xl relative inline-block" />
  </div>
  <div class="h-full w-full pr-4">
    <Skeleton
      class="w-full h-2 text-ellipsis mt-2 text-secondary-foreground text-sm text-balance"
    />
    <Skeleton class="w-3/5 h-2 text-ellipsis mt-2 text-secondary-foreground text-sm text-balance" />
  </div>
</div>
