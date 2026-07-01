import Link from "next/link";

export default function Home() {
  return (
    <main className="centered-page home-page">
      <section className="hero-panel home-hero">
        <div className="hero-copy">
          <p className="eyebrow">Eliminación directa</p>
          <h1>La copa se vive partido a partido.</h1>
          <p className="hero-description">
            Seguí cada cruce, resultado y definición por penales hasta conocer al campeón.
          </p>
          <div className="hero-actions">
            <Link className="primary-button" href="/torneos">
              Explorar torneos
            </Link>
            <Link className="secondary-button" href="/login">
              Ingresar como administrador
            </Link>
          </div>
          <div className="hero-features" aria-label="Características">
            <span>4 a 32 equipos</span>
            <span>Llave automática</span>
            <span>Resultados en vivo</span>
          </div>
        </div>
        <div className="hero-bracket" aria-hidden="true">
          <div className="preview-stage">
            <span>
              ARG <b>2</b>
            </span>
            <span>
              BRA <b>1</b>
            </span>
            <span>
              FRA <b>1</b>
            </span>
            <span>
              ESP <b>1</b>
            </span>
          </div>
          <div className="preview-connector" />
          <div className="preview-final">
            <small>Final</small>
            <span>
              ARG <b>3</b>
            </span>
            <span>
              FRA <b>1</b>
            </span>
          </div>
          <div className="preview-trophy">
            <small>Campeón</small>
            <strong>ARG</strong>
          </div>
        </div>
      </section>
    </main>
  );
}
