import type { User } from "@auth/sveltekit";

class UserStore {
  user = $state<User | null>(null);
}

const userStore = new UserStore();

export default userStore;
