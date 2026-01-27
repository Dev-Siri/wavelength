import { twMerge } from "tailwind-merge";

// Might look weird to copy an entire library into a project, but I'd rather not keep clsx in my package.json
type ClassValue =
  | ClassArray
  | ClassDictionary
  | string
  | number
  | bigint
  | null
  | boolean
  | undefined;
type ClassDictionary = Record<string, string>;
type ClassArray = ClassValue[];

function toValue(mix: ClassValue) {
  let string = "";

  if (typeof mix === "string" || typeof mix === "number" || typeof mix === "bigint") {
    string += mix;
  } else if (typeof mix === "object" && mix !== null) {
    if (Array.isArray(mix)) {
      for (const item of mix) {
        const y = toValue(item);
        if (y) {
          if (string) string += " ";
          string += y;
        }
      }
    } else {
      for (const key in mix) {
        if ((mix as ClassDictionary)[key]) {
          if (string) string += " ";
          string += key;
        }
      }
    }
  }

  return string;
}

function clsx(...inputs: ClassValue[]) {
  let className = "";

  for (const arg of inputs) {
    const x = toValue(arg);
    if (x) {
      if (className) className += " ";
      className += x;
    }
  }

  return className;
}

export default function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
