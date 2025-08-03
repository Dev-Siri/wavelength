<script lang="ts">
  import { page } from "$app/state";
  import { SearchIcon } from "@lucide/svelte";

  import { localStorageKeys } from "$lib/constants/keys";
  import musicPlayerStore from "$lib/stores/music-player.svelte";
  import { isRecentSearchesArray } from "$lib/utils/validation/recent-searches-schema";

  import SearchSuggestions from "./SearchSuggestions.svelte";

  const queryParam = page.url.searchParams.get("q") ?? "";

  let isInputFocused = $state(false);
  let isHoveringOverSuggestions = $state(false);
  let searchInput: HTMLInputElement;
  let q = $state(page.url.pathname.includes("/search") ? queryParam : "");

  $effect(() => {
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

  function handleStoringSearchTerms() {
    const storedSearches = localStorage.getItem(localStorageKeys.recentSearches);
    const parsedSearches = JSON.parse(storedSearches || "[]");

    if (!isRecentSearchesArray(parsedSearches)) return;

    if (parsedSearches.includes(q)) return;

    const newSearches = [q, ...parsedSearches.slice(0, 20)];
    localStorage.setItem(localStorageKeys.recentSearches, JSON.stringify(newSearches));
  }
</script>

{#if (isInputFocused || isHoveringOverSuggestions) && !musicPlayerStore.visiblePanel}
  <div
    class="absolute inset-0 top-full left-[5%] w-1/2 -ml-14 z-9999"
    role="list"
    onmouseenter={() => (isHoveringOverSuggestions = true)}
    onmouseleave={() => (isHoveringOverSuggestions = false)}
  >
    <SearchSuggestions {q} />
  </div>
{/if}
<form
  action="/app/search"
  method="GET"
  class="flex relative p-2 duration-200 w-full rounded-full border-2 border-secondary items-center bg-secondary gap-2 pl-4"
  class:focused-input={isInputFocused}
  onsubmit={handleStoringSearchTerms}
>
  <SearchIcon size={20} />
  <input
    type="text"
    name="q"
    placeholder="Search for Songs, Albums & Artists..."
    class="bg-transparent outline-hidden w-full"
    autocomplete="off"
    id="search-input"
    bind:value={q}
    bind:this={searchInput}
    onfocus={() => (isInputFocused = true)}
    onblur={() => (isInputFocused = false)}
  />
</form>

<style lang="postcss">
  @reference "tailwindcss";
  @config "../../../tailwind.config.ts";

  .focused-input {
    @apply border-primary border-2;
  }
</style>
