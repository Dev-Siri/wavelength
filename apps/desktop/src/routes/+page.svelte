<script lang="ts">
  import { goto } from "$app/navigation";
  import { resolve } from "$app/paths";
  import { ChevronDownIcon, PlayIcon, SkipBackIcon, SkipForwardIcon } from "@lucide/svelte";
  import rive from "@rive-app/canvas";
  import { isTauri } from "@tauri-apps/api/core";

  import wvlenDesktopUsage from "$lib/assets/wvlen-desktop-usage.png";
  import wvlenMobileUsage from "$lib/assets/wvlen-mobile-usage.png";
  import { getPlatform } from "$lib/utils/platform";

  import LandingFooter from "$lib/components/LandingFooter.svelte";
  import LandingHeader from "$lib/components/LandingHeader.svelte";
  import Button from "$lib/components/ui/button/button.svelte";
  import AndroidLogo from "$lib/components/vectors/AndroidLogo.svelte";
  import AppleLogo from "$lib/components/vectors/AppleLogo.svelte";
  import RecordDisc from "$lib/components/vectors/RecordDisc.svelte";
  import ShadowedLambda from "$lib/components/vectors/ShadowedLambda.svelte";
  import SpotifyLogo from "$lib/components/vectors/SpotifyLogo.svelte";
  import { APP_DOWNLOAD_LINKS } from "$lib/constants/download";

  let marqueeRef: HTMLDivElement;
  let waveCanvas: HTMLCanvasElement;

  let riveInstance: rive.Rive;

  $effect(() => {
    if (isTauri()) goto(resolve("/app"));

    async function createAnimations() {
      // @ts-expect-error GSAP's types don't work with dist/ imports
      const ScrollTriggerModule = await import("gsap/dist/ScrollTrigger");
      const ScrollTrigger = ScrollTriggerModule.ScrollTrigger;
      // @ts-expect-error GSAP's types don't work with dist/ imports
      const { gsap } = await import("gsap/dist/gsap");

      if (typeof window !== "undefined") {
        gsap.registerPlugin(ScrollTrigger);
        ScrollTrigger.defaults({ scroller: "main" });
      }

      gsap.from("h1", {
        opacity: 0,
        scale: 0.9,
        duration: 0.8,
        ease: "power2.out",
      });

      const subtextWords = document.querySelectorAll(".subtext-word");
      gsap.from(subtextWords, {
        opacity: 0,
        duration: 0.6,
        y: 10,
        delay: 0.4,
        ease: "power2.out",
        stagger: 0.05,
      });

      const albumPlaceholder = document.getElementById("album-placeholder");
      if (albumPlaceholder) {
        gsap.from(albumPlaceholder.children, {
          opacity: 0,
          y: 20,
          duration: 0.6,
          ease: "power2.out",
          stagger: {
            each: 0.1,
            from: "end",
          },
        });
      }

      const totalWidth = marqueeRef.scrollWidth / 2;
      gsap.to(marqueeRef, {
        x: -totalWidth,
        duration: 30,
        ease: "linear",
        repeat: -1,
        modifiers: {
          x: (x: string) => `${parseFloat(x) % -totalWidth}px`,
        },
      });

      const seeMoreLink = document.getElementById("see-more-link");
      if (seeMoreLink) {
        gsap.from(seeMoreLink, {
          opacity: 0,
          y: 10,
          duration: 0.6,
          delay: 1.5,
          ease: "power2.out",
        });
      }

      riveInstance = new rive.Rive({
        src: "/rive/wave.riv",
        canvas: waveCanvas,
        autoplay: true,
        onLoad: () => {
          riveInstance.resizeDrawingSurfaceToCanvas();
          ScrollTrigger.refresh();
        },
      });
    }

    if (typeof window !== "undefined") createAnimations();
    return () => {
      if (riveInstance) riveInstance.cleanup();
    };
  });

  $effect(() => {
    async function createAnimations() {
      // @ts-expect-error GSAP's types don't work with dist/ imports
      const { gsap } = await import("gsap/dist/gsap");

      gsap.from(
        "#features p, #features h4, #features .glow, #features #play-button, #features #record-player",
        {
          opacity: 0,
          y: 50,
          duration: 0.8,
          stagger: 0.2,
          ease: "power2.out",
          scrollTrigger: {
            trigger: "#features",
            start: "top 80%",
            end: "bottom 20%",
            toggleActions: "play none none reverse",
          },
        },
      );

      gsap.from("#mobile h4, #mobile p, #mobile img, #mobile div", {
        opacity: 0,
        y: 50,
        duration: 0.8,
        stagger: 0.2,
        ease: "power2.out",
        scrollTrigger: {
          trigger: "#mobile",
          start: "top 80%",
          end: "bottom 20%",
          toggleActions: "play none none reverse",
        },
      });

      gsap.to(".glow", {
        textShadow: "0 0 20px #ff1493, 0 0 30px #ff69b4",
        repeat: -1,
        yoyo: true,
        duration: 1,
        ease: "power1.inOut",
        scrub: true,
      });
    }

    if (typeof window !== "undefined") createAnimations();
  });

  function shuffleArray<T>(array: T[]): T[] {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  }

  const ALBUM_COUNT = 10;
  let previewIndex = $state(0);

  function previewNext() {
    if (previewIndex < ALBUM_COUNT - 1) {
      previewIndex += 1;
    } else {
      previewIndex = 0;
    }
  }

  function previewPrevious() {
    if (previewIndex > 0) {
      previewIndex -= 1;
    } else {
      previewIndex = ALBUM_COUNT - 1;
    }
  }

  const albums = shuffleArray(Array.from({ length: ALBUM_COUNT }, (_, i) => i));
  const platform = getPlatform();

  const downloadLink = APP_DOWNLOAD_LINKS[platform] || APP_DOWNLOAD_LINKS.android;
</script>

<LandingHeader />
<main class="h-[90vh] scroll-smooth w-screen bg-[#111] overflow-y-auto pb-20 scrollbar-hidden">
  <article class="flex flex-col items-center gap-10 w-full justify-between mt-20">
    <section class="flex flex-col items-center w-full">
      <div class="shadow-xl">
        <ShadowedLambda />
      </div>
      <h1
        class="text-primary mt-4 leading-tighter text-4xl font-semibold xl:text-6xl xl:tracking-tighter max-w-4xl"
      >
        Wavelength
      </h1>
      <p
        id="subtext"
        class="text-foreground text-base text-center text-balance sm:text-2xl font-semibold my-4"
      >
        {#each "Stream any song from YouTube Music with the best audio quality and zero ads, all for free.".split(" ") as word, i (i)}
          <span class="subtext-word inline-block ml-[5px]">{word}</span>
        {/each}
      </p>
      <div class="flex gap-2">
        <div class="flex gap-2">
          <Button
            href={downloadLink}
            class="flex gap-2 items-center rounded-full"
            size="lg"
            download
            target="_blank"
            rel="noreferrer noopener"
          >
            <p class="text-md">Download Wavelength</p>
          </Button>
        </div>
      </div>
      <div class="overflow-hidden w-full mt-12 relative">
        <div id="album-placeholder" class="flex gap-4" bind:this={marqueeRef}>
          {#each [...albums, ...albums] as i, actualIndex (actualIndex)}
            <div class="min-h-48 min-w-48 rounded-xl overflow-hidden bg-secondary/90">
              <img
                src="/promotion-albums/album-{i + 1}.png"
                draggable="false"
                alt="Promotional Album"
              />
            </div>
          {/each}
        </div>
      </div>
      <a href="#features" id="see-more-link" class="mt-8 text-[#828282]">
        <ChevronDownIcon />
      </a>
    </section>
    <section id="features" class="w-full px-4 lg:px-20">
      <div
        class="relative bg-[#212121] shadow-inner shadow-gray-600 w-full h-96 rounded-4xl flex flex-col items-center justify-center overflow-hidden"
      >
        <canvas
          bind:this={waveCanvas}
          class="absolute w-[200%] blur-xs align-middle -ml-[50%] grayscale-100 opacity-50 aspect-video h-[150%] inset-0"
        ></canvas>
        <p class="font-bold text-3xl md:text-4xl text-gray-400">Lossless</p>
        <h4 class="font-bold text-6xl md:text-8xl relative z-10">
          1,411<span class="text-5xl">kbps+</span>
        </h4>
        <p class="font-bold text-3xl md:text-4xl text-center relative z-10">
          Preserve <span class="glow">every</span> detail in your music.
        </p>
      </div>
      <div class="flex flex-col md:flex-row mt-5 gap-5">
        <div
          class="relative bg-[#212121] md:flex-1 shadow-inner shadow-gray-600 px-4 text-center w-full h-96 rounded-4xl flex flex-col items-center justify-center overflow-hidden"
        >
          <p class="font-bold text-4xl">No Ads</p>
          <p class="font-bold text-2xl">Just pure uninterrupted music.</p>
          <div class="bg-white p-4 rounded-full mt-4 animate-pulse" id="play-button">
            <PlayIcon fill="black" size={44} />
          </div>
        </div>
        <div
          class="bg-[#212121] md:flex-2 shadow-inner shadow-gray-600 w-full h-96 px-4 text-center rounded-4xl flex flex-col items-center justify-center overflow-hidden"
        >
          <div id="record-player" class="flex items-center gap-12">
            <div
              role="button"
              tabindex="0"
              onkeydown={previewPrevious}
              onclick={previewPrevious}
              class="cursor-pointer hidden md:block select-none"
            >
              <SkipBackIcon size={32} fill="white" />
            </div>
            <div class="relative select-none">
              <div class="animate-spin">
                <RecordDisc />
              </div>
              <div>
                <img
                  src="/promotion-albums/album-{previewIndex + 1}.png"
                  alt="Album Art"
                  class="absolute top-1/2 left-1/2 w-24 h-24 rounded-full -translate-x-1/2 -translate-y-1/2"
                />
              </div>
            </div>
            <div
              role="button"
              tabindex="0"
              onkeydown={previewNext}
              onclick={previewNext}
              class="cursor-pointer hidden md:block select-none"
            >
              <SkipForwardIcon size={32} fill="white" />
            </div>
          </div>
          <p class="font-bold text-3xl md:text-4xl mt-4">Virtually an Infinite Library.</p>
          <p class="font-bold text-gray-400 text-xl md:text-2xl">
            Wavelength has everything you can get on <SpotifyLogo /> and some more.
          </p>
        </div>
      </div>
    </section>
    <section id="mobile" class="text-start px-4 md:px-20">
      <h4
        class="text-primary mt-4 leading-tighter text-4xl font-semibold xl:text-5xl tracking-tighter"
      >
        Listen on the go with Wavelength on your phone.
      </h4>
      <p class="font-bold text-gray-400 text-xl mt-2 md:text-2xl">
        The mobile app allows you to download your music in Lossless and listen offline, anywhere
        you are, no matter the connection.
      </p>
      <div class="flex flex-col md:flex-row gap-5 mt-4 items-center">
        <div
          class="bg-[#212121] relative shadow-inner shadow-gray-600 w-full h-96 p-4 text-center rounded-4xl flex items-center justify-center overflow-hidden"
        >
          <img
            src={wvlenMobileUsage}
            alt="Wavelength Mobile Usage."
            class="rounded-4xl overflow-hidden h-full w-full object-contain pulse-normal"
            height="200"
            width="200"
          />
          <img
            src={wvlenDesktopUsage}
            alt="Wavelength Desktop Usage."
            class="absolute rounded-3xl overflow-hidden px-8 h-full w-full object-contain pulse-opposite"
            height="200"
            width="200"
          />
        </div>
        <div
          class="bg-[#212121] shadow-inner shadow-gray-600 w-full h-96 px-4 text-center rounded-4xl flex flex-col items-center justify-center overflow-hidden"
        >
          <p class="font-bold text-2xl">Sync your library across devices.</p>
          <p class="font-bold text-2xl">Download your favorite songs.</p>
          <p class="font-bold text-2xl">Connect your devices seamlessly.</p>
        </div>
        <div
          class="bg-[#212121] shadow-inner shadow-gray-600 w-full h-96 px-4 text-center rounded-4xl flex flex-col items-center justify-center overflow-hidden"
        >
          <p class="font-bold text-3xl">Available on major platforms.</p>
          <p class="flex font-bold text-2xl mt-4 gap-4 items-center">
            <AndroidLogo height={70} width={70} />
            Android.
          </p>
          <p class="flex font-bold text-2xl gap-4 items-center">
            <span class="scale-200 invert">
              <AppleLogo />
            </span>
            macOS
          </p>
          <p class="flex font-bold text-2xl gap-4 mt-8 items-center">
            <span class="grid grid-cols-2 grid-rows-2 gap-0.5">
              <span class="h-5 w-5 bg-blue-700"></span>
              <span class="h-5 w-5 bg-blue-700"></span>
              <span class="h-5 w-5 bg-blue-700"></span>
              <span class="h-5 w-5 bg-blue-700"></span>
            </span>
            Windows
          </p>
        </div>
      </div>
    </section>
    <section
      id="what-are-you-waiting-for"
      class="bg-[#212121] relative shadow-inner shadow-gray-600 mb-40 w-full h-64 px-4 text-center flex flex-col items-center justify-center overflow-hidden mt-10"
    >
      <h4
        class="text-primary mt-4 leading-tighter text-4xl font-semibold xl:text-5xl tracking-tighter"
      >
        So, what are you waiting for?
      </h4>
      <Button href="/app" class="flex gap-2 items-center rounded-full mt-6 w-fit" size="lg">
        <p class="text-md">Start Listening</p>
      </Button>
      <p
        class="absolute right-10 top-10 -mt-88 opacity-50 font-black pointer-events-none select-none text-[550px]"
      >
        λ
      </p>
    </section>
  </article>
  <LandingFooter />
</main>

<style>
  .glow {
    color: #fff;
    text-shadow:
      0 0 5px #fff,
      0 0 10px #ffb6c1,
      0 0 15px #ff69b4,
      0 0 20px #ff1493;
  }

  @keyframes pulse-opposite {
    0%,
    100% {
      opacity: 0;
    }
    50% {
      opacity: 1;
    }
  }

  @keyframes pulse-normal {
    0%,
    100% {
      opacity: 1;
    }
    50% {
      opacity: 0;
    }
  }

  .pulse-normal {
    animation: pulse-normal 5s infinite;
  }

  .pulse-opposite {
    animation: pulse-opposite 5s infinite;
  }
</style>
