<script lang="ts">
  import type { FullArtist } from "$lib/utils/validation/artist-response";

  import { buttonVariants } from "$lib/components/ui/button";
  import * as Card from "$lib/components/ui/card";
  import { openUrl } from "$lib/utils/url";

  const { artist }: { artist: FullArtist } = $props();

  const normalizedDescription = $derived.by(() => {
    const wikipediaLine = artist.description?.indexOf("From Wikipedia");
    if (!wikipediaLine) return "";

    return artist.description?.slice(0, wikipediaLine) ?? "";
  });

  const artistLink = $derived(`https://music.youtube.com/channel/${artist.browseId}`);
</script>

<Card.Root class="bg-border">
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
