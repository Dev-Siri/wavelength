<script lang="ts">
  import { isTauri } from "@tauri-apps/api/core";
  import { platform } from "@tauri-apps/plugin-os";

  import {
    desktopOnlySettings,
    playbackQualities,
    playbackQualityMap,
    type SettingDescriptionOption,
  } from "$lib/constants/settings";
  import settingsStore from "$lib/stores/settings.svelte";

  import * as NativeSelect from "$lib/components/ui/native-select";
  import * as Select from "$lib/components/ui/select";
  import { Switch } from "$lib/components/ui/switch";

  const { setting }: { setting: SettingDescriptionOption } = $props();
  const { title, description, settingKey, webHint } = setting;

  const isMac = isTauri() && platform() === "macos";

  let value = $state(settingsStore.settings.playbackQuality);
</script>

<div class="flex items-center justify-between p-4">
  <div>
    <p class="text-lg font-semibold">{title}</p>
    <p class="text-sm text-muted-foreground">{description}</p>
    {#if webHint && !isTauri()}
      <p class="text-xs mt-0.5 text-blue-500">{webHint}</p>
    {/if}
  </div>
  {#if settingKey === "playbackQuality"}
    {#if isMac}
      <NativeSelect.Root
        bind:value
        onchange={() => settingsStore.updateSettings({ playbackQuality: value })}
      >
        {#each playbackQualities as { key, uiText } (key)}
          <NativeSelect.Option value={key} disabled={!isTauri()}>
            {uiText}
          </NativeSelect.Option>
        {/each}
      </NativeSelect.Root>
    {:else}
      <Select.Root
        type="single"
        bind:value
        disabled={!isTauri()}
        onValueChange={newValue =>
          settingsStore.updateSettings({
            playbackQuality: newValue as typeof settingsStore.settings.playbackQuality,
          })}
      >
        <Select.Trigger>
          {isTauri() ? playbackQualityMap[value] : playbackQualityMap["hifiTop"]}
        </Select.Trigger>
        <Select.Content>
          {#each playbackQualities as { key, uiText } (key)}
            <Select.Item value={key}>
              {uiText}
            </Select.Item>
          {/each}
        </Select.Content>
      </Select.Root>
    {/if}
  {:else}
    <Switch
      checked={settingsStore.settings[settingKey] as boolean}
      onCheckedChange={isChecked => settingsStore.updateSettings({ [settingKey]: isChecked })}
      disabled={desktopOnlySettings.includes(settingKey) && !isTauri()}
    />
  {/if}
</div>
