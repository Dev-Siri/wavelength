<script lang="ts">
  /* eslint-disable svelte/no-navigation-without-resolve */
  import { goto } from "$app/navigation";
  import { blur } from "svelte/transition";

  import useSearchRecommendationsQuery from "$lib/queries/searchRecommendations";

  import { resolve } from "$app/paths";
  import Image from "../Image.svelte";

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

  const searchRecommendationsQuery = $derived(useSearchRecommendationsQuery(q));

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
        searchRecommendationsQuery.data?.matchingQueries.length ?? 0 - 1,
      );
    }

    if (e.key === "ArrowUp") {
      if (activeIndex === 0) searchInput?.focus();

      e.preventDefault();
      activeIndex = Math.max(activeIndex - 1, 0);
    }

    if (e.key === "Enter") {
      const term = searchRecommendationsQuery.data?.matchingQueries[activeIndex];
      if (term) goto(`/app/search?q=${encodeURIComponent(term)}`);
    }
  }
</script>

{#if searchRecommendationsQuery.data?.matchingQueries.length || searchRecommendationsQuery.data?.matchingLinks?.length || q}
  <!-- svelte-ignore a11y_no_noninteractive_tabindex -->
  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <div
    in:blur
    out:blur
    role="list"
    class="bg-primary-foreground h-full w-2/5 shadow-2xl border-secondary rounded-sm flex flex-col items-center py-2 outline-none"
    bind:this={searchSuggestionsList}
    onkeydown={handleSearchSuggestionListKeyDown}
    onfocus={onFocus}
    onblur={onBlur}
    tabindex="0"
  >
    {#each searchRecommendationsQuery.data?.matchingQueries.slice(0, 3) as searchTerm, i (`${searchTerm}-${i}`)}
      <li
        class="flex justify-center relative items-center h-full w-full backdrop-opacity-20 z-9999"
        class:bg-secondary={i === activeIndex}
      >
        <a
          href="/app/search?q={encodeURIComponent(searchTerm)}"
          class="h-full w-full p-4 hover:bg-secondary duration-200"
        >
          {#each searchTerm.split("") as char, i (`${char}-${i}`)}
            {#if char === q.charAt(i)}
              <span class="font-semibold">{char}</span>
            {:else}
              {char}
            {/if}
          {/each}
        </a>
      </li>
    {/each}
    {#each searchRecommendationsQuery.data?.matchingLinks?.slice(0, 6) as searchLink, i (`${searchLink.title}-${i}`)}
      <li
        class="flex justify-center relative items-center h-full w-full backdrop-opacity-20 z-9999"
        class:bg-secondary={i === activeIndex}
      >
        {#if searchLink.type === "album" || searchLink.type === "artist"}
          <a
            href={resolve(`/app/${searchLink.type}/${searchLink.browseId}`)}
            class="flex items-center p-2 h-full gap-2 w-full hover:bg-secondary duration-200"
          >
            <Image
              src={searchLink.thumbnail}
              alt="{searchLink.title} Thumbnail"
              height={40}
              width={40}
              class={searchLink.type === "album" ? "rounded-sm" : "rounded-full"}
            />
            <div class="flex flex-col">
              <span class="font-semibold">{searchLink.title}</span>
              <span class="text-xs text-gray-400">{searchLink.subtitle}</span>
            </div>
          </a>
        {/if}
      </li>
    {/each}
  </div>
{/if}
