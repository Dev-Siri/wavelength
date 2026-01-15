<script lang="ts">
  import wvlenUsagePhone from "$lib/assets/wvlen-usage-phone.png";
  import wvlenUsageTablet from "$lib/assets/wvlen-usage-tablet.png";

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
  <article class="flex items-center px-20 gap-10 w-full justify-between mt-20">
    <section class="flex flex-col h-full items-start w-1/2">
      <h1 class="font-black text-6xl leading-tight">Music you love, right at your fingertips.</h1>
      <p class="text-2xl my-6 ml-1">Ad-free, offline downloads, no unnecessary AI.</p>
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
    <section class="flex flex-col h-full justify-center w-1/2 relative">
      <img
        src={wvlenUsageTablet}
        alt="Wavelength Usage Tablet"
        height="1160"
        width="2240"
        class="rounded-3xl border-4 border-muted"
      />
      <img
        src={wvlenUsagePhone}
        alt="Wavelength Usage Phone"
        height="1240"
        width="260"
        class="absolute inset-0 right-full top-1/6 -mt-10 -ml-20"
      />
    </section>
  </article>
</main>
