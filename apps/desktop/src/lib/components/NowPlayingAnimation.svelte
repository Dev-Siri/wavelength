<div class="flex items-center justify-center w-10 h-10">
  <div class="flex items-end w-5 h-5 gap-[10%] playing">
    <div class="bar"></div>
    <div class="bar"></div>
    <div class="bar"></div>
    <div class="bar"></div>
  </div>
</div>

<style lang="postcss">
  @reference "tailwindcss";
  @import "../../../tailwind.config.ts";

  .playing .bar {
    @apply inline-block h-full w-[10%] mx-[2%] bg-white;
    animation: wobble 1.2s infinite;
    animation-timing-function: cubic-bezier(0.4, 0.2, 0.6, 0.8);
    animation-fill-mode: both;
  }

  .playing .bar:nth-child(2) {
    animation-delay: -0.7s;
  }

  .playing .bar:nth-child(3) {
    animation-delay: -0.35s;
  }

  .playing .bar:nth-child(4) {
    animation-delay: -1.05s;
  }

  @keyframes wobble {
    0% {
      height: 20%;
    }
    50% {
      height: 100%;
    }
    100% {
      height: 20%;
    }
  }
</style>
