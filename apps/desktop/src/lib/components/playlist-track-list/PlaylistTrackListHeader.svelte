<script lang="ts">
  import { ClockIcon, HashIcon } from "@lucide/svelte";

  const {
    albumColShown = true,
  }: {
    albumColShown?: boolean;
  } = $props();
</script>

<header class="flex items-center select-none text-muted-foreground">
  <section class="flex items-center gap-10 w-1/3">
    <div class="cursor-pointer p-1.5 pl-4.5 rounded-full duration-200">
      <HashIcon size={14} />
    </div>
    <p class="text-sm">Title</p>
  </section>
  <section class="flex justify-center w-1/3">
    <p class="text-sm {albumColShown ? 'opacity-100' : 'opacity-0'}">Album</p>
  </section>
  <section class="flex justify-center w-1/3">
    <ClockIcon size={14} class="mr-6" />
  </section>
</header>
<div class="bg-secondary h-[1px] w-full my-2.5 rounded-full"></div>
