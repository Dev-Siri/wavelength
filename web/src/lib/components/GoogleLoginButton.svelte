<script lang="ts">
  import { signIn } from "@auth/sveltekit/client";

  import { Button } from "./ui/button";
  import GoogleLogo from "./vectors/GoogleLogo.svelte";
</script>

<Button onclick={() => signIn("google")} class="gap-1">
  <GoogleLogo />
  <span class="hidden sm:block">Sign in with Google</span>
</Button>
