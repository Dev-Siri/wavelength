<script lang="ts">
  import { goto } from "$app/navigation";
  import { resolve } from "$app/paths";

  import type { EmbeddedAlbum } from "$lib/schemas/embedded";

  import cn from "$lib/utils/cn";

  import { Button } from "../ui/button";

  const { browseId, title, class: className }: EmbeddedAlbum & { class?: string } = $props();

  const albumPath = $derived(`/app/album/${browseId}` as const);

  function handleNavigation(
    e:
      | (MouseEvent & { currentTarget: EventTarget & HTMLButtonElement })
      | (MouseEvent & { currentTarget: EventTarget & HTMLAnchorElement }),
  ) {
    e.preventDefault();
    e.stopPropagation();

    goto(resolve(albumPath));
  }
</script>

<Button
  variant="link"
  class={cn("text-sm text-muted-foreground", className)}
  href={albumPath}
  onclick={handleNavigation}
>
  {title.length > 30 ? `${title.slice(0, 29).trim()}...` : title}
</Button>
