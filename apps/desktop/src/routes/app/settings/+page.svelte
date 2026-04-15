<script lang="ts">
  import { advancedSettings, displaySettings, playbackSettings } from "$lib/constants/settings";

  import SettingOption from "./setting-option.svelte";
</script>

<div class="flex flex-col gap-2 h-full w-full select-none overflow-y-auto pb-[20%] bg-black p-4">
  <h1 class="font-semibold text-2xl mb-2">Settings</h1>
  <span class="font-semibold text-lg">Display</span>
  <div class="bg-[#111] pr-4 rounded-2xl">
    {#each displaySettings as setting, i (setting.settingKey)}
      <div class={i + 1 !== displaySettings.length ? "border-b-2 border-b-border" : ""}>
        <SettingOption {setting} />
      </div>
    {/each}
  </div>
  <span class="font-semibold text-lg">Audio</span>
  <div class="bg-[#111] pr-4 rounded-2xl">
    {#each playbackSettings as setting, i (setting.settingKey)}
      <div class={i + 1 !== playbackSettings.length ? "border-b-2 border-b-border" : ""}>
        <SettingOption {setting} />
      </div>
    {/each}
  </div>
  <span class="font-semibold text-lg">Advanced</span>
  <div class="bg-[#111] pr-4 rounded-2xl">
    {#each advancedSettings as setting, i (setting.settingKey)}
      <div class={i + 1 !== advancedSettings.length ? "border-b-2 border-b-border" : ""}>
        <SettingOption {setting} />
      </div>
    {/each}
  </div>
</div>
