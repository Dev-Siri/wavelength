<script lang="ts">
  import wvlenUsageHero from "$lib/assets/wvlen-usage-hero.png";

  import LandingHeader from "$lib/components/LandingHeader.svelte";
  import Button from "$lib/components/ui/button/button.svelte";
  import AndroidLogo from "$lib/components/vectors/AndroidLogo.svelte";

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
  <article
    class="flex flex-col lg:flex-row items-center px-4 lg:px-20 gap-10 w-full justify-between mt-20"
  >
    <section class="flex flex-col h-full items-center lg:items-start w-full lg:w-2/5">
      <h1
        class="font-black leading-tight text-balance text-center lg:text-start text-3xl sm:text-4xl md:text-6xl lg:text-5xl"
      >
        Music you love, <br />right at your fingertips.
      </h1>
      <p class="text-lg sm:text-xl lg:text-2xl my-6 ml-1 text-center text-balance lg:text-start">
        Ad-free, offline downloads, $0/month.
      </p>
      <div class="flex gap-2">
        <div class="flex gap-2">
          <Button href="/downloads" class="flex gap-2 items-center" size="lg">
            <AndroidLogo />
            <p class="text-md">Download</p>
          </Button>
        </div>
        <Button href="/app" class="flex gap-2 items-center" variant="secondary" size="lg">
          <span class="font-bold text-2xl">λ</span>
          <p class="text-md">Web Player</p>
        </Button>
      </div>
    </section>
    <section class="flex flex-col h-full justify-center w-full lg:w-3/5">
      <img src={wvlenUsageHero} alt="Wavelength Usage Hero" height="2160" width="3040" />
    </section>
  </article>
</main>
