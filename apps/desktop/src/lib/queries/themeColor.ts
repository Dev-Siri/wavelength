import { get, set } from "idb-keyval";

import { svelteQueryKeys } from "$lib/constants/keys";
import { themeColorSchema } from "$lib/schemas/theme-color";
import { backendClient } from "$lib/utils/query-client";
import { createQuery } from "@tanstack/svelte-query";

export interface ThemeColorQueryOptions {
  cacheKey?: string;
  enabled?: () => boolean;
}

export default function useThemeColorQuery(
  thumbnail: string,
  { cacheKey, enabled }: ThemeColorQueryOptions = {},
) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.themeColor(thumbnail),
    enabled,
    async queryFn() {
      if (!thumbnail) {
        return null;
      }
      if (!cacheKey) {
        return backendClient(`/image/theme-color`, themeColorSchema, {
          searchParams: { imageUrl: thumbnail },
        });
      }

      const themeColorKey = `theme-color-${cacheKey}`;
      const cachedThemeColor = await get(themeColorKey);
      const isColorValid = themeColorSchema.safeParse(cachedThemeColor);

      if (!isColorValid.success) {
        const themeColor = await backendClient("/image/theme-color", themeColorSchema, {
          searchParams: {
            imageUrl: thumbnail,
          },
        });

        await set(themeColorKey, themeColor);
        return themeColor;
      }

      const themeColor = themeColorSchema.parse(isColorValid.data);
      return themeColor;
    },
  }));
}
