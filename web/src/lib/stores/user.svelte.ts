import { z } from "zod";

import type { User } from "@auth/sveltekit";

import { localStorageKeys } from "$lib/constants/keys";
import { backendClient } from "$lib/utils/query-client";

class UserStore {
  user = $state<User | null>(null);
  authToken = $state<string | null>(null);
}

export async function getAuthToken(user: User) {
  const storedAuthToken = localStorage.getItem(localStorageKeys.authToken);

  if (storedAuthToken) return storedAuthToken;

  const createdAuthToken = await backendClient("/auth/token", z.string(), {
    method: "POST",
    body: {
      id: user.id,
      email: user.email,
      displayName: user.name,
      photoUrl: user.image,
    },
  });

  localStorage.setItem(localStorageKeys.authToken, createdAuthToken);
  return createdAuthToken;
}

const userStore = new UserStore();

export default userStore;
