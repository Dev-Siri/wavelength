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
  let castValue = $state(settingsStore.settings.castAudioQuality ?? "standard");
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
        onchange={() =>
          settingsStore.updateSettings({
            // @ts-expect-error conditionally defined.
            [settingKey]: settingKey === "castAudioQuality" ? castValue : value,
          })}
      >
        {#each playbackQualities as { key, uiText } (key)}
          <NativeSelect.Option
            value={key}
            disabled={!isTauri() && settingKey === "playbackQuality"}
          >
            {uiText}
          </NativeSelect.Option>
        {/each}
      </NativeSelect.Root>
    {:else}
      <Select.Root
        type="single"
        bind:value
        disabled={!isTauri() && settingKey === "playbackQuality"}
        onValueChange={newValue =>
          settingsStore.updateSettings({
            [settingKey]: newValue as typeof settingsStore.settings.playbackQuality,
          })}
      >
        <Select.Trigger>
          {isTauri() ||
          // @ts-expect-error conditionally defined.
          settingKey === "castAudioQuality"
            ? playbackQualityMap[
                // @ts-expect-error conditionally defined.
                settingKey === "castAudioQuality" ? castValue : value
              ]
            : playbackQualityMap["hifiTop"]}
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
  {:else if settingKey === "castAudioQuality" && !isTauri()}
    {#if isMac}
      <NativeSelect.Root
        bind:value={castValue}
        onchange={() =>
          settingsStore.updateSettings({
            castAudioQuality: castValue,
          })}
      >
        {#each playbackQualities as { key, uiText } (key)}
          <NativeSelect.Option value={key}>
            {uiText}
          </NativeSelect.Option>
        {/each}
      </NativeSelect.Root>
    {:else}
      <Select.Root
        type="single"
        bind:value={castValue}
        onValueChange={newValue => {
          castValue = newValue as typeof castValue;
          settingsStore.updateSettings({
            castAudioQuality: castValue,
          });
        }}
      >
        <Select.Trigger>
          {playbackQualityMap[castValue]}
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
      checked={settingKey !== "castAudioQuality" && (settingsStore.settings[settingKey] as boolean)}
      onCheckedChange={isChecked => settingsStore.updateSettings({ [settingKey]: isChecked })}
      disabled={desktopOnlySettings.includes(settingKey) && !isTauri()}
    />
  {/if}
</div>
