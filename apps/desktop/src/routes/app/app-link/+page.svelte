<script lang="ts">
  import macAppUsage from "$lib/assets/mac-app-usage.png";

  import wavelengthLogo from "$lib/assets/logo.svg";
  import Logo from "$lib/components/Logo.svelte";
  import Button from "$lib/components/ui/button/button.svelte";
  import { APP_DOWNLOAD_LINKS } from "$lib/constants/download";
  import { getPlatform } from "$lib/utils/platform";

  const platform = getPlatform();
  const formattedPlatform = $derived.by(() => {
    switch (platform) {
      case "windows":
        return "Windows";
      case "darwin":
        return "Mac";
      default:
        return "Desktop";
    }
  });

  const downloadLink = APP_DOWNLOAD_LINKS[platform] || APP_DOWNLOAD_LINKS.darwin;
</script>

<svelte:head>
  <title>Download for {formattedPlatform}</title>
</svelte:head>

<div class="h-full w-full bg-black">
  <div class="flex bg-muted h-2/3 w-full rounded-4xl">
    <section class="h-full flex flex-col justify-center w-2/3 py-20 pl-20">
      <div class="flex items-center">
        <Logo />
        <img
          src={wavelengthLogo}
          alt="WaveLength logo"
          draggable="false"
          height="200"
          width="200"
        />
      </div>
      <h1
        class="text-primary leading-tighter tracking-tight text-balance font-semibold text-3xl xl:tracking-tighter mt-10"
      >
        Download Wavelength for {formattedPlatform}
      </h1>
      <p class="w-1/2 text-lg my-10">
        Enjoy high-quality audio, offline playback, downloads, and a faster experience.
      </p>
      <Button
        href={downloadLink}
        size="sm"
        class="w-fit px-10"
        download
        target="_blank"
        rel="noreferrer noopener"
      >
        Get Wavelength for {formattedPlatform}
      </Button>
    </section>
    <section class="h-full w-1/3 flex flex-col items-center justify-center">
      <img
        src={macAppUsage}
        alt="Mac App Usage"
        height="2000"
        width="3000"
        class="scale-200 translate-x-1/6"
      />
    </section>
  </div>
</div>
