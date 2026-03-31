import { createQuery } from "@tanstack/svelte-query";
import { get, set } from "idb-keyval";

import { svelteQueryKeys } from "$lib/constants/keys";
import { coverEffectSchema } from "$lib/schemas/theme-color";
import { backendClient } from "$lib/utils/query-client";

export interface CoverEffectQueryOptions {
  cacheKey?: string;
  enabled?: () => boolean;
}

export default function useCoverEffectQuery(
  thumbnail: string,
  { cacheKey, enabled }: CoverEffectQueryOptions = {},
) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.coverEffect(thumbnail),
    enabled,
    async queryFn() {
      if (!cacheKey) {
        return backendClient(`/image/theme-color`, coverEffectSchema, {
          searchParams: { imageUrl: thumbnail },
        });
      }

      const coverEffectKey = `cover-effect-${cacheKey}`;
      const cachedCoverEffectColors = await get(coverEffectKey);
      const isColorValid = coverEffectSchema.safeParse(cachedCoverEffectColors);

      if (!isColorValid.success) {
        const coverEffect = await backendClient("/image/cover-effect", coverEffectSchema, {
          searchParams: {
            imageUrl: thumbnail,
          },
        });

        await set(coverEffectKey, coverEffect);
        return coverEffect;
      }

      const coverEffect = coverEffectSchema.parse(isColorValid.data);
      return coverEffect;
    },
  }));
}
