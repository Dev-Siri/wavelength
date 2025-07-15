<div aria-busy="true" aria-label="Loading" class="relative inline-block h-52 w-52 group">
  <svg class="absolute top-0 left-0 w-full h-full spinner-svg" viewBox="0 0 100 100">
    <circle
      cx="50"
      cy="50"
      r="45"
      fill="none"
      stroke="gray"
      stroke-width="2"
      stroke-dasharray="30, 10"
    />
  </svg>
  <p
    class="absolute top-1/2 left-1/2 m-0 font-black text-8xl select-none group-hover:opacity-50 duration-200"
  >
    λ
  </p>
  <p
    class="absolute top-1/2 left-1/2 m-0 font-medium text-4xl select-none group-hover:opacity-100 opacity-0 duration-200"
  >
    Loading
  </p>
</div>

<style>
  .spinner-svg {
    animation: spin 10s linear infinite;
  }

  p {
    transform: translate(-50%, -50%);
  }

  @keyframes spin {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }
</style>
