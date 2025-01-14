<script lang="ts">
  import { page } from "$app/stores";
  import { Search } from "lucide-svelte";
  import { onMount } from "svelte";

  const queryParam = $page.url.searchParams.get("q") ?? "";

  let isInputFocused = false;
  let searchInput: HTMLInputElement;

  onMount(() => {
    function focusHandler(e: KeyboardEvent) {
      // Basically, when the search input isn't focused, it will call .focus()
      // and also, not actually type in the slash. So kinda repurposing the key
      // and only doing it if a content-editable/input/textarea is already not in focus
      // Because otherwise it will cause "/" to not be typable in inputs.

      if (
        e.key === "/" &&
        document.activeElement !== searchInput &&
        document.activeElement instanceof HTMLElement &&
        !["INPUT", "TEXTAREA"].includes(document.activeElement.tagName) &&
        !document.activeElement.isContentEditable
      ) {
        e.preventDefault();
        searchInput.focus();
      }
    }

    document.addEventListener("keydown", focusHandler);

    return () => document.removeEventListener("keydown", focusHandler);
  });
</script>

<form
  action="/search"
  method="GET"
  class="flex p-2 duration-200 w-full rounded-full border-2 border-secondary items-center bg-secondary gap-2 pl-4"
  class:focused-input={isInputFocused}
>
  <Search size={20} />
  <input
    type="text"
    name="q"
    placeholder="Search for Songs, Albums & Artists..."
    class="bg-transparent outline-none w-full"
    autocomplete="off"
    id="search-input"
    value={$page.url.pathname.includes("/search") ? queryParam : ""}
    bind:this={searchInput}
    on:focus={() => (isInputFocused = true)}
    on:blur={() => (isInputFocused = false)}
  />
</form>

<style lang="postcss">
  .focused-input {
    @apply border-primary border-2;
  }
</style>
