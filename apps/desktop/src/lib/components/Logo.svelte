<script lang="ts">
  import cn from "$lib/utils/cn";

  const { class: className }: { class?: string } = $props();
</script>

<span class={cn("font-black text-5xl select-none", className)}>λ</span>
