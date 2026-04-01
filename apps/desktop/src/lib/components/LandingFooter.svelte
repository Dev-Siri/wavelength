<script>
  import { GithubIcon } from "@lucide/svelte";
  import Logo from "./Logo.svelte";

  const GITHUB_URL = "https://github.com/Dev-Siri/wavelength";
</script>

<footer class="h-[5vh] flex items-center mt-20 gap-2 px-20 w-full">
  <Logo />
  <p class="text-center font-semibold text-lg">Wavelength</p>
  <div class="ml-auto">
    <a
      target="_blank"
      href={GITHUB_URL}
      class="text-muted-foreground hover:text-primary transition-all"
    >
      <GithubIcon />
    </a>
  </div>
</footer>
