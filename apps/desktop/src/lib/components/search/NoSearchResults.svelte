<script lang="ts">
  const { message }: { message: string } = $props();
</script>

<div class="flex flex-col items-center h-full justify-center relative">
  <span class="font-black text-4xl rotate-12 top-0 right-2/6 absolute">!</span>
  <span class="font-black text-8xl select-none">λ</span>
  <span class="text-lg text-balance mt-2">{message}</span>
</div>
