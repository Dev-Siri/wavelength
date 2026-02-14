export function getLuminance(r: number, g: number, b: number) {
  const srgb = [r, g, b].map(v => {
    v /= 255;
    return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  });

  return 0.2126 * srgb[0] + 0.7152 * srgb[1] + 0.0722 * srgb[2];
}

export function mapOpacity(luminance: number) {
  const MIN = 0.1;
  const MAX = 0.3;

  return MAX - luminance * (MAX - MIN);
}
