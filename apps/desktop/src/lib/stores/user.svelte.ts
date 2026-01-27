import type { User } from "@auth/sveltekit";

class UserStore {
  user = $state<User | null>(null);
  authToken = $state<string | null>(null);
}

const userStore = new UserStore();

export default userStore;
