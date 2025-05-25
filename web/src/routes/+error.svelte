<script lang="ts">
  import { page } from "$app/state";
  import Button from "$lib/components/ui/button/button.svelte";
</script>

<div class="flex flex-col h-screen w-screen items-center justify-center">
  <h4 class="text-9xl">
    {page.status}
  </h4>
  <div class="bg-red h-0.5 w-full"></div>
  <p class="text-3xl">
    {page.error?.message ?? "An error occured."}
  </p>
  <Button href="/app" class="mt-4">
    {#if page.status === 404}
      Return to the Web Player
    {:else}
      Try Again
    {/if}
  </Button>
</div>
