export function arraysEqual<T>(a: T[], b: T[]) {
  return a.length === b.length && a.every((val, i) => val === b[i]);
}
