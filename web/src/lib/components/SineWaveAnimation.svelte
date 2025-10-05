<script lang="ts">
  const {
    amplitude = 50,
    frequency = 0.02,
    speed = 0.05,
    lineColor = "#ffffff",
    midLineColor = "#888",
  }: {
    /** @default 50 */
    amplitude?: number;
    /** @default 0.02 */
    frequency?: number;
    /** @default 0.05 */
    speed?: number;
    lineColor?: `#${string}`;
    midLineColor?: `#${string}`;
  } = $props();

  let canvas: HTMLCanvasElement;
  let ctx: CanvasRenderingContext2D | null = null;

  let phase = $state(0);
  let size = $state({ width: 800, height: 300 });

  $effect(() => {
    // Set canvas size to match element size
    const resize = () => {
      size.width = canvas.clientWidth;
      size.height = canvas.clientHeight;
      canvas.width = size.width;
      canvas.height = size.height;
    };

    resize();
    window.addEventListener("resize", resize);
    ctx = canvas.getContext("2d");

    const animate = () => {
      phase += speed;
      draw();
      requestAnimationFrame(animate);
    };

    if (ctx) animate();

    return () => {
      window.removeEventListener("resize", resize);
    };
  });

  function draw() {
    if (!ctx) return;

    ctx.clearRect(0, 0, size.width, size.height);

    // Midline
    ctx.beginPath();
    ctx.moveTo(0, size.height / 2);
    ctx.lineTo(size.width, size.height / 2);
    ctx.strokeStyle = midLineColor;
    ctx.lineWidth = 1;
    ctx.stroke();

    // Sine wave
    ctx.beginPath();
    for (let x = 0; x < size.width; x++) {
      const y = size.height / 2 + amplitude * Math.sin(frequency * x + phase);
      ctx.lineTo(x, y);
    }
    ctx.strokeStyle = lineColor;
    ctx.lineWidth = 2;
    ctx.stroke();
  }
</script>

<canvas bind:this={canvas}></canvas>

<style>
  canvas {
    width: 100%;
    height: 300px;
    display: block;
  }
</style>
