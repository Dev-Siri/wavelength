type UrlValidity =
  | {
      isValid: false;
    }
  | {
      isValid: true;
      url: URL;
    };

export function checkUrlValidity(uncheckedString: string): UrlValidity {
  try {
    const urlRegex = /(https?:\/\/[^\s)\]}>"]+)/;
    const match = uncheckedString.match(urlRegex);

    if (match) {
      const cleanedUrl = match[0];
      const url = new URL(cleanedUrl);

      return { isValid: true, url };
    }

    return { isValid: false };
  } catch {
    return { isValid: false };
  }
}
