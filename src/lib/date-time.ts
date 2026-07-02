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

const argentinaDateTimeFormatter = new Intl.DateTimeFormat("es-AR", {
  dateStyle: "short",
  hour12: false,
  timeStyle: "short",
  timeZone: "America/Argentina/Buenos_Aires",
});

export function formatDateTime24Hour(value: string) {
  return argentinaDateTimeFormatter.format(new Date(value));
}
