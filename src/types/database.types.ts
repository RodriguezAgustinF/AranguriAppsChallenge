export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

/**
 * Tipo inicial del esquema público todavía vacío.
 * Se reemplaza ejecutando `npm run db:types` o `npm run db:types:local`.
 */
export type Database = {
  public: {
    Tables: Record<string, never>;
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: Record<string, never>;
    CompositeTypes: Record<string, never>;
  };
};
