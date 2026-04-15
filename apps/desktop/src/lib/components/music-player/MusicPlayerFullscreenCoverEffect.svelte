<script lang="ts">
  import { blur } from "svelte/transition";

  import type { ThemeColor } from "$lib/schemas/image";

  const { coverColors }: { coverColors: ThemeColor[] } = $props();

  const coverEffectBackgroundBlurColors = $derived(coverColors.slice(1));

  let blobs = $derived(
    coverEffectBackgroundBlurColors.map(c => ({
      ...c,
      x: Math.random() * 100,
      y: Math.random() * 100,
      vx: (Math.random() - 0.5) * 0.02,
      vy: (Math.random() - 0.5) * 0.02,
      size: 450 + Math.random() * 150,
    })),
  );

  let mouseX = $state(0);
  let mouseY = $state(0);
  let centerX = $state(window.innerWidth / 2);
  let centerY = $state(window.innerHeight / 2);

  function handleMouseMove(e: MouseEvent) {
    mouseX = e.clientX;
    mouseY = e.clientY;
  }

  function loop() {
    const offsetX = (mouseX - centerX) * 0.01;
    const offsetY = (mouseY - centerY) * 0.01;

    blobs = blobs.map(b => {
      const x = b.x + b.vx + offsetX * 0.02;
      const y = b.y + b.vy + offsetY * 0.02;

      if (x < 0 || x > 100) b.vx *= -1;
      if (y < 0 || y > 100) b.vy *= -1;

      return { ...b, x, y };
    });

    setTimeout(() => requestAnimationFrame(loop), 1000);
  }

  $effect(() => {
    window.addEventListener("mousemove", handleMouseMove);
    return () => window.removeEventListener("mousemove", handleMouseMove);
  });

  loop();
</script>

{#each blobs as { r, g, b, x, y, size }, i (i)}
  <div
    in:blur
    class="absolute inset-0 will-change-transform blur-[84px] pointer-events-none rounded-full blob"
    style="
        background-color: rgb({r}, {g}, {b}, 0.2);
        width: {size}px;
        height: {size}px;
        left: {x}%;
        top: {y}%;
      "
  ></div>
{/each}

<style>
  .blob {
    animation: float 12s ease-in-out infinite alternate;
  }

  @keyframes float {
    0% {
      transform: translate(0, 0) scale(1);
    }

    50% {
      transform: translate(60px, -40px) scale(1.1);
    }

    100% {
      transform: translate(-40px, 50px) scale(0.95);
    }
  }
</style>
