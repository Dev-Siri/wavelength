<script lang="ts">
  import type { Artist } from "$lib/schemas/artist";

  import { openUrl } from "$lib/utils/url";

  import { buttonVariants } from "$lib/components/ui/button";
  import * as Card from "$lib/components/ui/card";

  const { artist }: { artist: Artist } = $props();

  const normalizedDescription = $derived.by(() => {
    const wikipediaLine = artist.description?.indexOf("From Wikipedia");
    if (!wikipediaLine) return "";

    return artist.description?.slice(0, wikipediaLine) ?? "";
  });

  const artistLink = $derived(`https://music.youtube.com/channel/${artist.browseId}`);
</script>

<Card.Root class="bg-border mb-[20%]">
  <Card.Header>
    <Card.Title>{artist.title}</Card.Title>
  </Card.Header>
  <Card.Content class="text-sm leading-relaxed">
    {normalizedDescription}
  </Card.Content>
  <Card.Footer>
    <Card.Action class={buttonVariants({ variant: "default" })} onclick={() => openUrl(artistLink)}>
      View on YouTube Music
    </Card.Action>
  </Card.Footer>
</Card.Root>
