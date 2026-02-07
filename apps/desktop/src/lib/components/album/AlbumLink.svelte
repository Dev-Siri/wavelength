<script lang="ts">
  import { goto } from "$app/navigation";

  import type { EmbeddedAlbum } from "$lib/utils/validation/albums";

  import cn from "$lib/utils/cn";

  import { Button } from "../ui/button";

  const { browseId, title, class: className }: EmbeddedAlbum & { class?: string } = $props();

  const albumPath = `/app/album/${browseId}`;

  function handleNavigation(
    e:
      | (MouseEvent & { currentTarget: EventTarget & HTMLButtonElement })
      | (MouseEvent & { currentTarget: EventTarget & HTMLAnchorElement }),
  ) {
    e.preventDefault();
    e.stopPropagation();

    goto(albumPath);
  }
</script>

<Button
  variant="link"
  class={cn("p-0 m-0 h-4 -mt-2 mr-1 text-sm text-muted-foreground", className)}
  href={albumPath}
  onclick={handleNavigation}
>
  {title}
</Button>
