<script lang="ts">
  import { durationify } from "$lib/utils/format";

  const { duration }: { duration: string | number } = $props();

  const formattedDuration = durationify(Number(duration));
</script>

<p class="text-xs text-muted-foreground">
  {formattedDuration}
</p>
