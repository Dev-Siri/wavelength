<script lang="ts">
  import { X } from "lucide-svelte";

  import { localStorageKeys } from "$lib/constants/keys";
  import { isRecentSearchesArray } from "$lib/utils/validation/recent-searches-schema";

  let { q }: { q: string } = $props();

  let searchTerms = $state<string[]>([]);
  let filteredSearchTerms = $derived(
    q ? searchTerms.filter(term => term.includes(q)) : searchTerms,
  );

  $effect(() => {
    function fetchRecentSearches() {
      const recentSearches = localStorage.getItem(localStorageKeys.recentSearches);

      if (!recentSearches) return;

      const jsonRecentSearches = JSON.parse(recentSearches);
      const parsedRecentSearches = isRecentSearchesArray(jsonRecentSearches);

      if (parsedRecentSearches) searchTerms = jsonRecentSearches;
    }

    fetchRecentSearches();
  });

  function removeTermFromRecents(searchTerm: string) {
    searchTerms = searchTerms.filter(term => term !== searchTerm);

    localStorage.setItem(localStorageKeys.recentSearches, JSON.stringify(searchTerms));
  }
</script>

<div class="bg-black rounded-2xl w-full overflow-hidden shadow-2xl">
  {#if filteredSearchTerms.length}
    <ul>
      {#each filteredSearchTerms as searchTerm}
        <li class="flex justify-center items-center h-full w-full backdrop-opacity-20 z-9999">
          <a
            href="/app/search?q={encodeURIComponent(searchTerm)}"
            class="h-full w-full p-4 hover:bg-secondary duration-200"
          >
            {#each searchTerm.split("") as char, i}
              {#if char === q[i]}
                <span class="font-semibold">{char}</span>
              {:else}
                {char}
              {/if}
            {/each}
          </a>
          <button
            type="button"
            class="h-fit cursor-pointer p-4 hover:bg-red-500 duration-200"
            onclick={() => removeTermFromRecents(searchTerm)}
          >
            <X size={20} />
          </button>
        </li>
      {/each}
    </ul>
  {:else}
    <p class="text-center text-gray-400 p-4">Try searching for songs, artists and videos...</p>
  {/if}
</div>
