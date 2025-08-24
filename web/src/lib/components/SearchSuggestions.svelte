<script lang="ts">
  import { XIcon } from "@lucide/svelte";

  import { localStorageKeys } from "$lib/constants/keys.js";
  import { isRecentSearchesArray } from "$lib/utils/validation/recent-searches-schema.js";

  let { q }: { q: string } = $props();

  let searchTerms = $state<string[]>([]);
  let filteredSearchTerms = $derived(
    q ? searchTerms.filter(term => term.includes(q.toLowerCase())) : searchTerms,
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

  function handleRemoveTermFromRecents(
    e: MouseEvent & {
      currentTarget: EventTarget & HTMLButtonElement;
    },
    searchTerm: string,
  ) {
    e.stopPropagation();
    e.preventDefault();

    searchTerms = searchTerms.filter(term => term !== searchTerm);

    localStorage.setItem(localStorageKeys.recentSearches, JSON.stringify(searchTerms));
  }
</script>

<div class="bg-black border-2 border-secondary rounded-xl w-full overflow-hidden shadow-2xl">
  {#if filteredSearchTerms.length}
    <div class="py-4">
      <p class="px-4 text-xl font-semibold mb-4">Recent Searches</p>
      <ul class="flex flex-col items-center">
        {#each filteredSearchTerms as searchTerm}
          <li
            class="flex justify-center relative items-center h-full w-full backdrop-opacity-20 z-9999"
          >
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
              <button
                type="button"
                class="absolute inset-0 top-1/6 left-[92%] h-fit w-fit rounded-full p-2 cursor-pointer hover:bg-red-500 duration-200"
                onclick={e => handleRemoveTermFromRecents(e, searchTerm)}
              >
                <XIcon size={20} />
              </button>
            </a>
          </li>
        {/each}
      </ul>
    </div>
  {:else}
    <p class="text-center text-gray-400 p-4">Try searching for songs, artists and videos...</p>
  {/if}
</div>
