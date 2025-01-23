/**
 * Defaults to 500ms debounce.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export default function debounce<T extends (...args: any[]) => void>(
  func: T,
  delay: number = 500,
): (...args: Parameters<T>) => void {
  let timeoutId: ReturnType<typeof setTimeout>;

  return function (...args: Parameters<T>): void {
    if (timeoutId) {
      clearTimeout(timeoutId);
    }
    timeoutId = setTimeout(() => {
      func(...args);
    }, delay);
  };
}
