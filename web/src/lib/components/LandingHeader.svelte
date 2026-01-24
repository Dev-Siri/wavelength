<script lang="ts">
  import wavelengthLogo from "$lib/assets/logo.svg";
  import userStore from "$lib/stores/user.svelte";

  import GoogleLoginButton from "./action-buttons/GoogleLoginButton.svelte";
  import UserProfileIcon from "./UserProfileIcon.svelte";
</script>

<header class="h-[10vh] flex justify-between items-center w-screen bg-black p-4">
  <a href="/">
    <img src={wavelengthLogo} alt="WaveLength logo" draggable="false" height="200" width="200" />
  </a>
  {#if userStore.user}
    <UserProfileIcon />
  {:else}
    <GoogleLoginButton />
  {/if}
</header>
