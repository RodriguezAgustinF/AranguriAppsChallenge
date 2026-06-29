import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Prode de Fútbol",
  description: "Torneos eliminatorios y pronósticos de fútbol.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  );
}
