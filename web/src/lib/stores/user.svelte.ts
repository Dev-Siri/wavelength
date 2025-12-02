import { z } from "zod";

import type { User } from "@auth/sveltekit";

import { localStorageKeys } from "$lib/constants/keys";
import { backendClient } from "$lib/utils/query-client";

class UserStore {
  user = $state<User | null>(null);
}

export async function getAuthToken() {
  if (!userStore.user) return;

  const storedAuthToken = localStorage.getItem(localStorageKeys.authToken);

  if (storedAuthToken) return storedAuthToken;

  const createdAuthToken = await backendClient("/auth/token", z.string(), {
    method: "POST",
    body: {
      id: userStore.user.id,
      email: userStore.user.email,
      displayName: userStore.user.name,
      photoUrl: userStore.user.image,
    },
  });

  localStorage.setItem(localStorageKeys.authToken, createdAuthToken);
  return createdAuthToken;
}

const userStore = new UserStore();

export default userStore;
