<script>
  import Skeleton from "../ui/skeleton/skeleton.svelte";
</script>

<div class="flex items-center gap-4">
  <Skeleton class="h-32 w-32 rounded-md" />
  <div class="flex flex-col gap-2">
    <Skeleton class="h-4 w-64 rounded-md" />
    <Skeleton class="h-4 w-48 rounded-md" />
    <Skeleton class="h-11 w-16 mt-4 rounded-md" />
  </div>
</div>
