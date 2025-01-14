import configureRegion from "$lib/server/utils/configure-region";

export async function load({ locals, cookies, getClientAddress }) {
  const session = await locals.auth();

  const region = configureRegion(cookies, getClientAddress());

  return { session, region };
}
