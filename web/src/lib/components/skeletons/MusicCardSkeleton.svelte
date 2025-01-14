<script lang="ts">
  import Skeleton from "../ui/skeleton/skeleton.svelte";
</script>

<div role="presentation" class="relative flex flex-col w-52 p-2 rounded-2xl cursor-pointer group">
  <div class="h-44 w-48 p-3 relative rounded-2xl">
    <Skeleton class="h-full w-full rounded-2xl relative inline-block thumbnail-cover" />
  </div>
  <Skeleton class="w-full h-2 text-ellipsis mt-2 text-secondary-foreground text-sm text-balance" />
  <Skeleton class="w-3/5 h-2 text-ellipsis mt-2 text-secondary-foreground text-sm text-balance" />
</div>
