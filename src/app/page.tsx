import Link from "next/link";

export default function Home() {
  return (
    <main className="centered-page">
      <section className="hero-panel">
        <p className="eyebrow">Eliminación directa</p>
        <h1>Torneos de fútbol</h1>
        <p className="muted-text">
          Consultá las llaves y resultados o ingresá para administrar la competencia.
        </p>
        <div className="hero-actions">
          <Link className="primary-button" href="/torneos">
            Ver torneos
          </Link>
          <Link className="secondary-button" href="/login">
            Administración
          </Link>
        </div>
      </section>
    </main>
  );
}
