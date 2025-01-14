<script lang="ts">
  import { ExternalLink } from "lucide-svelte";

  import { checkUrlValidity } from "$lib/utils/url";
  import { Button } from "./ui/button";

  export let text: string;
  let className: string = "";

  export { className as class };

  const words = text.split(" ");
</script>

<span class={className}>
  {#each words as word}
    {@const urlValidity = checkUrlValidity(word)}
    {#if urlValidity.isValid}
      <Button
        href={urlValidity.url.toString()}
        variant="link"
        target="_blank"
        referrerpolicy="no-referrer"
        class="inline-flex gap-1 p-0 items-center"
      >
        ({urlValidity.url.hostname}
        <ExternalLink size={14} class="-mr-1" />)
      </Button>
    {:else}
      {word}
    {/if}
    {" "}
  {/each}
</span>
