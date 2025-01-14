<script>
  import { Skeleton } from "../ui/skeleton";
</script>

<div class="flex gap-2 p-2">
  <Skeleton class="rounded-md h-11 w-12" />
  <div class="flex flex-col gap-2 w-full mt-2">
    <Skeleton class="w-4/5 rounded-full h-2" />
    <Skeleton class="w-3/5 rounded-full h-2" />
  </div>
</div>
