<script lang="ts">
  import { page } from "$app/state";
  import { Music } from "lucide-svelte";

  import errorBanner from "$lib/assets/error-banner.svg";
</script>

<div class="flex flex-col items-center justify-center">
  <div class="blurred-div absolute -z-10 left-1/3"></div>
  <div class="blurred-div absolute -z-10 left-[53%]"></div>
  <img src={errorBanner} alt="Error Banner" class="bg-cover error-banner" draggable={false} />
  <div class="flex gap-2 items-center self-start pl-[200px]">
    <Music color="red" />
    <p class="text-2xl font-bold text-red-600">{page.error?.message}</p>
  </div>
</div>

<style>
  .error-banner {
    box-shadow: outset 0 0 1000px #242322;
  }

  .blurred-div {
    margin: 10px auto;
    filter: blur(50px); /* Blurs the background behind the div */
    background: rgba(43, 43, 43, 0.664);
    opacity: 0.8;
    border-radius: 100%; /* Rounded corners */
    box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1); /* Soft shadow */
  }

  .blurred-div:nth-child(1) {
    width: 550px;
    height: 500px;
  }

  .blurred-div:nth-child(2) {
    width: 500px;
    height: 400px;
  }
</style>
