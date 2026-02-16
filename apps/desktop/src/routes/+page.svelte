<script lang="ts">
  import wvlenUsageHero from "$lib/assets/wvlen-usage-hero.png";

  import LandingHeader from "$lib/components/LandingHeader.svelte";
  import Button from "$lib/components/ui/button/button.svelte";
  import AndroidLogo from "$lib/components/vectors/AndroidLogo.svelte";
</script>

<LandingHeader />
<main class="h-[90vh] w-screen bg-black overflow-y-auto pb-20">
  <article
    class="flex flex-col lg:flex-row items-center px-4 lg:px-20 gap-10 w-full justify-between mt-20"
  >
    <section class="flex flex-col h-full items-center lg:items-start w-full lg:w-2/5">
      <h1
        class="text-primary leading-tighter text-4xl font-semibold tracking-tight text-balance lg:leading-[1.1] xl:text-5xl xl:tracking-tighter max-w-4xltext-center lg:text-start"
      >
        Music you love, <br />right at your fingertips.
      </h1>
      <p class="text-foreground max-w-3xl text-base text-balance sm:text-lg my-4">
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
