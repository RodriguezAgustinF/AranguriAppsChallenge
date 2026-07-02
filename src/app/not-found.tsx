import Link from "next/link";

export default function NotFound() {
  return (
    <main className="not-found-page">
      <section className="not-found-content">
        <p className="eyebrow">Error 404</p>
        <h1>Página no encontrada</h1>
        <p>
          La dirección que ingresaste no existe o el contenido dejó de estar disponible. Podés
          volver al inicio o consultar los torneos publicados.
        </p>
        <div className="not-found-actions">
          <Link className="primary-button" href="/">
            Volver al inicio
          </Link>
          <Link className="secondary-button" href="/torneos">
            Ver torneos
          </Link>
        </div>
      </section>
      <span className="not-found-code" aria-hidden="true">
        404
      </span>
    </main>
  );
}
