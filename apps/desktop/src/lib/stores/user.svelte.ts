import type { AuthUser } from "$lib/utils/validation/auth";

class UserStore {
  user = $state<AuthUser | null>(null);
  authToken = $state<string | null>(null);
}

const userStore = new UserStore();

export default userStore;
