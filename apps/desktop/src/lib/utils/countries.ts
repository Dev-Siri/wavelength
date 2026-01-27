import countries from "$lib/constants/countries.js";

export function codeToCountryName(cc: string) {
  const country = countries.find(({ code }) => code === cc);

  return country?.name ?? "the United States";
}
