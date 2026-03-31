<script lang="ts">
  import type { MusicTrack } from "$lib/schemas/music-track";

  import Image from "$lib/components/Image.svelte";
  import * as Card from "$lib/components/ui/card";
  import { Progress } from "$lib/components/ui/progress";

  const { track, progressPercent }: { track: MusicTrack; progressPercent: number } = $props();
</script>

<Card.Root>
  <Card.Header>
    <Card.Title>Downloading {track.title}</Card.Title>
    <Card.Action>
      <Image
        src={track.thumbnail}
        alt="{track.thumbnail}'s Cover"
        height={80}
        width={80}
        class="rounded-xl aspect-square object-cover"
      />
    </Card.Action>
  </Card.Header>
  <Card.Content>
    <p class="mb-2 text-sm text-muted-foreground">{progressPercent.toFixed(2)}% completed</p>
    <Progress value={progressPercent} />
  </Card.Content>
</Card.Root>
