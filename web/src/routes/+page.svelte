<script lang="ts">
  import LandingHeader from "$lib/components/LandingHeader.svelte";
  import SineWaveAnimation from "$lib/components/SineWaveAnimation.svelte";
  import Button from "$lib/components/ui/button/button.svelte";
  import AndroidLogo from "$lib/components/vectors/AndroidLogo.svelte";
  import SpotifyGlyph from "$lib/components/vectors/SpotifyGlyph.svelte";
  import YouTubeLogo from "$lib/components/vectors/YouTubeLogo.svelte";

  let screenWidth = $state(0);

  $effect(() => {
    screenWidth = window.innerWidth;

    const handleResize = () => (screenWidth = window.innerWidth);

    window.addEventListener("resize", handleResize);

    return () => window.removeEventListener("resize", handleResize);
  });
</script>

<LandingHeader />
<main class="h-[90vh] w-screen bg-black overflow-y-auto pb-20">
  <article class="flex flex-col items-center text-center">
    <div
      class="p-10 rounded-full aspect-square my-10 pointer-events-none select-none rotating-border"
    >
      <span class="font-bold text-[156px]">λ</span>
    </div>
    <div class="flex flex-col items-center mb-10 -mt-10">
      <p class="flex items-center gap-1.5 text-lg sm:text-2xl text-wrap">
        It's the
        <span class="mr-1 -mt-1">
          <SpotifyGlyph
            height={screenWidth < 475 ? 100 : 120}
            width={screenWidth < 475 ? 100 : 120}
          />
        </span>that doesn't beg you for your money.
      </p>
      <p class="text-lg sm:text-2xl text-balance w-full -mt-4">
        if its on <span class="inline ml-1">
          <YouTubeLogo height={screenWidth < 475 ? 35 : 40} width={screenWidth < 475 ? 35 : 40} />
        </span>, its available for your
        <span class="underline-animate">playlist</span>.
      </p>
    </div>
    <div class="absolute inset-0 top-3/5">
      <SineWaveAnimation />
    </div>
    <div class="px-[5%] md:px-[10%] flex flex-col items-center z-50">
      <div class="flex flex-col gap-2 mt-2">
        <div class="flex gap-2">
          <Button href="/downloads" class="flex gap-2 items-center" size="lg">
            <AndroidLogo />
            <p class="text-md">Download for Mobile</p>
          </Button>
        </div>
        <Button href="/app" class="flex gap-2 items-center" variant="secondary" size="lg">
          <span class="font-bold text-2xl">λ</span>
          <p class="text-md">Open Web Player</p>
        </Button>
      </div>
    </div>
  </article>
</main>

<style>
  .underline-animate {
    position: relative;
    display: inline-block;
    font-weight: bold;
  }

  .underline-animate::after {
    content: "";
    position: absolute;
    left: 0;
    bottom: 0;
    width: 100%;
    height: 3px;
    background-color: red;
    transform: scaleX(0);
    transform-origin: left;
    animation: cartoon-underline 0.7s ease-out 0.4s forwards;
    border-radius: 2px;
  }

  @keyframes cartoon-underline {
    0% {
      transform: scaleX(0);
    }
    40% {
      transform: scaleX(1.05);
    }
    60% {
      transform: scaleX(0.95);
    }
    100% {
      transform: scaleX(1);
    }
  }

  .rotating-border {
    position: relative;
  }

  .rotating-border::before {
    content: "";
    position: absolute;
    inset: 0;
    border: 2px dashed transparent;
    background-image: radial-gradient(circle at center, #222 2px, transparent 2.5px);
    background-size: 15px 15px;
    background-repeat: repeat;
    border-radius: 9999px;
    animation: spin-border 20s linear infinite;
    z-index: 0;
    box-sizing: border-box;
    aspect-ratio: 1 / 1;
  }

  .rotating-border > * {
    position: relative;
    z-index: 10;
  }

  @keyframes spin-border {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }
</style>
