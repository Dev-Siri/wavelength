<script>
  import { ChevronLeft } from "@lucide/svelte";

  import LandingHeader from "$lib/components/LandingHeader.svelte";
  import Button from "$lib/components/ui/button/button.svelte";
  import AndroidLogo from "$lib/components/vectors/AndroidLogo.svelte";

  const downloadUrl =
    "https://github.com/Dev-Siri/wavelength/releases/latest/download/app-release.apk";
</script>

<LandingHeader />
<main class="h-[90vh] w-screen bg-black overflow-y-auto pb-20 flex flex-col items-center">
  <article class="max-w-3xl pb-10 px-6 flex flex-col items-start text-left">
    <Button href="/" class="flex gap-2 px-4 items-center" size="lg" variant="ghost">
      <ChevronLeft />
      <p class="text-md">Back to Home</p>
    </Button>
    <h1 class="block text-4xl py-4">Download for Android</h1>
    <Button
      href={downloadUrl}
      class="flex gap-2 px-4 items-center"
      size="lg"
      download
      target="_blank"
      rel="noreferrer noopener"
    >
      <AndroidLogo />
      <p class="text-md">Download APK for Android</p>
    </Button>
    <p class="py-4">
      Click on the download button below to get the APK file for Wavelength on Android. After the
      download completes, open the APK file to install Wavelength on your device. Please note that
      you may need to enable installation from unknown sources in your device settings because you
      are downloading an application from outside the Google Play Store.
    </p>
    <p>
      If Android asks you whether you want to send the app to Google Play Protect's security
      analysis, make sure you deny it. Wavelength is not on the Play Store, so Google can't analyze
      it. However, Wavelength is completely safe to use, it's code is also open-source and available
      for review on
      <a
        href="https://github.com/Dev-Siri/wavelength"
        target="_blank"
        rel="noreferrer noopener"
        class="underline"
      >
        GitHub
      </a> in case of any suspicion.
    </p>
  </article>
</main>
