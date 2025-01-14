export function compactify(statCount: number) {
  const formatter = Intl.NumberFormat("en", {
    compactDisplay: "short",
    notation: "compact",
    minimumFractionDigits: 1,
    maximumFractionDigits: 1,
  });

  return formatter.format(statCount);
}

export function durationify(seconds: number) {
  const minutes = Math.floor(seconds / 60);
  const formattedSeconds = Math.floor(seconds % 60);

  return `${minutes}:${formattedSeconds}`;
}

export function parseDurationToSeconds(duration: string) {
  const [minutesStr, secondsStr] = duration.split(":");
  const [minutes, seconds] = [Number(minutesStr), Number(secondsStr)];
  const minutesInSeconds = minutes * 60;

  return minutesInSeconds + seconds;
}

export function parseHtmlEntities(htmlString: string) {
  const parser = new DOMParser();
  const decodedString = parser.parseFromString(htmlString, "text/html").body.textContent;
  return decodedString;
}
