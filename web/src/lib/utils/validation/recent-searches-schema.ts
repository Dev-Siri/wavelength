export function isRecentSearchesArray(array: unknown): array is string[] {
  return Array.isArray(array) && !array.some(item => typeof item !== "string");
}
