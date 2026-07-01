export function toLocalDateTimeInput(value?: string | null) {
  if (!value) return "";

  const date = new Date(value);
  return new Date(date.getTime() - date.getTimezoneOffset() * 60_000).toISOString().slice(0, 16);
}

export function localDateTimeToIso(value: string) {
  if (!value) return "";

  const date = new Date(value);
  return Number.isNaN(date.valueOf()) ? "" : date.toISOString();
}
