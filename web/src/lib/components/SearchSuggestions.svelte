<script lang="ts">
  import { goto } from "$app/navigation";
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";
  import { searchRecommendationsSchema } from "$lib/utils/validation/search-recommendations";

  let searchSuggestionsList: HTMLDivElement | null = $state(null);
  let {
    q,
    isInputFocused,
    searchInput,
    onFocus,
    onBlur,
  }: {
    q: string;
    isInputFocused: boolean;
    searchInput: HTMLInputElement | null;
    onFocus?: () => void;
    onBlur?: () => void;
  } = $props();

  const cachedQueries = new Set<string>();
  const searchRecommendationsQuery = createQuery(() => ({
    initialData: {
      matchingQueries: [],
      matchingLinks: [],
    },
    staleTime: query => (cachedQueries.has(query.queryKey[1]) ? 1000 * 60 * 5 : 0),
    refetchOnMount: false,
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    queryKey: svelteQueryKeys.searchRecommendations(q),
    queryFn: () => {
      if (!cachedQueries.has(q)) cachedQueries.add(q);
      return backendClient("/music/search/search-recommendations", searchRecommendationsSchema, {
        searchParams: { q },
      });
    },
  }));

  $effect(() => {
    function keyboardSuggestionNavigationHandler(e: KeyboardEvent) {
      if (!isInputFocused) return;

      if (e.key === "ArrowDown") searchSuggestionsList?.focus();
    }

    document.addEventListener("keydown", keyboardSuggestionNavigationHandler);

    return () => document.removeEventListener("keydown", keyboardSuggestionNavigationHandler);
  });

  let activeIndex = $state(0);

  function handleSearchSuggestionListKeyDown(e: KeyboardEvent) {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      activeIndex = Math.min(
        activeIndex + 1,
        searchRecommendationsQuery.data.matchingQueries.length - 1,
      );
    }

    if (e.key === "ArrowUp") {
      if (activeIndex === 0) searchInput?.focus();

      e.preventDefault();
      activeIndex = Math.max(activeIndex - 1, 0);
    }

    if (e.key === "Enter") {
      const term = searchRecommendationsQuery.data.matchingQueries[activeIndex];
      if (term) goto(`/app/search?q=${encodeURIComponent(term)}`);
    }
  }
</script>

<div class="bg-black border-secondary rounded-xl w-full overflow-hidden shadow-2xl">
  {#if searchRecommendationsQuery.data.matchingQueries.length || searchRecommendationsQuery.data?.matchingLinks?.length || q}
    <!-- svelte-ignore a11y_no_noninteractive_tabindex -->
    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <div
      role="list"
      class="flex flex-col items-center py-4 outline-none"
      bind:this={searchSuggestionsList}
      onkeydown={handleSearchSuggestionListKeyDown}
      onfocus={onFocus}
      onblur={onBlur}
      tabindex="0"
    >
      {#each searchRecommendationsQuery.data.matchingQueries.slice(0, 3) as searchTerm, i}
        <li
          class="flex justify-center relative items-center h-full w-full backdrop-opacity-20 z-9999"
          class:bg-secondary={i === activeIndex}
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
          </a>
        </li>
      {/each}
    </div>
  {/if}
</div>
