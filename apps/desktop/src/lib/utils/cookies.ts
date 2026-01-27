export function getCookie(key: string) {
  const name = `${key}=`;
  const decodedCookie = decodeURIComponent(document.cookie);

  const regex = new RegExp(`(?:^|;\\s*)${name}([^;]*)`);
  const match = decodedCookie.match(regex);

  const value = match?.[1] ? match[1] : "";

  return value;
}

export function setCookie(key: string, value: string) {
  const expireDate = new Date(9999, 0, 1).toUTCString();

  document.cookie = `${key}=${value};expires=${expireDate};path=/;samesite=strict`;
}
