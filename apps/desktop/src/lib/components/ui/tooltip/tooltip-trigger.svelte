<script lang="ts">
  import cn from "$lib/utils/cn";
  import { Tooltip as TooltipPrimitive } from "bits-ui";

  let { ref = $bindable(null), ...restProps }: TooltipPrimitive.TriggerProps = $props();

  let isBouncing = $state(false);

  function handleClick(e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement }) {
    restProps.onclick?.(e);
    isBouncing = true;
    setTimeout(() => (isBouncing = false), 400);
  }
</script>

<TooltipPrimitive.Trigger
  bind:ref
  data-slot="tooltip-trigger"
  {...restProps}
  class={cn(restProps.class, isBouncing && "animate-tap-bounce")}
  onclick={handleClick}
/>
