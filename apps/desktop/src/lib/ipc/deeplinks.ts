import { goto } from "$app/navigation";
import { resolve } from "$app/paths";
import { z } from "zod";

import { localStorageKeys } from "$lib/constants/keys";
import { authUserSchema } from "$lib/schemas/auth";
import userStore from "$lib/stores/user.svelte";
import { backendClient } from "$lib/utils/query-client";

export async function setupDeeplinkUrlActions(urls: string[]) {
  for (const url of urls) {
    const parsed = new URL(url);

    // wavlen://authCallback
    if (parsed.hostname === "authCallback") {
      const authCode = parsed.searchParams.get("code");
      if (!authCode || userStore.authToken) return;
      const { authToken } = await backendClient(
        "/auth/token/consume",
        z.object({ authToken: z.string() }),
        { searchParams: { code: authCode } },
      );

      const authUser = await backendClient("/auth/profile", authUserSchema, {
        headers: {
          Authorization: `Bearer ${authToken}`,
        },
      });

      localStorage.setItem(localStorageKeys.authUser, JSON.stringify(authUser));
      localStorage.setItem(localStorageKeys.authToken, authToken);

      userStore.user = authUser;
      userStore.authToken = authToken;
    }

    // wavlen://playlist/*
    if (parsed.hostname === "playlist") {
      const playlistId = parsed.pathname.replace("/", "");
      goto(resolve("/app/playlist/[playlistId]", { playlistId }));
    }

    // wavlen://album/*
    if (parsed.hostname === "album") {
      const albumId = parsed.pathname.replace("/", "");
      goto(resolve("/app/album/[albumId]", { albumId }));
    }
  }
}
