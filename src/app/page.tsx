import Link from "next/link";

import { PublicFooter } from "@/components/layout/public-footer";
import { PublicHeader } from "@/components/layout/public-header";

export default function Home() {
  return (
    <div className="public-shell">
      <PublicHeader />
      <main className="site-home">
        <section className="website-hero">
          <div className="site-container website-hero-inner">
            <div className="hero-copy">
              <p className="eyebrow">Torneos de eliminación directa</p>
              <h1>Una competencia. Un cuadro. Un campeón.</h1>
              <p className="hero-description">
                Organizá y consultá equipos, partidos, horarios y resultados desde el sorteo inicial
                hasta la gran final.
              </p>
              <div className="hero-actions">
                <Link className="primary-button" href="/torneos">
                  Ver todos los torneos
                </Link>
                <a className="hero-text-link" href="#como-funciona">
                  Cómo funciona ↓
                </a>
              </div>
            </div>
            <div className="hero-bracket" aria-label="Ejemplo de una llave de eliminación directa">
              <div className="preview-stage">
                <small>Semifinales</small>
                <span>
                  Argentina <b>2</b>
                </span>
                <span>
                  Brasil <b>1</b>
                </span>
                <span>
                  Francia <b>1</b>
                </span>
                <span>
                  España <b>1</b>
                </span>
              </div>
              <div className="preview-connector" />
              <div className="preview-final">
                <small>Final</small>
                <span>
                  Argentina <b>3</b>
                </span>
                <span>
                  Francia <b>1</b>
                </span>
              </div>
              <div className="preview-trophy">
                <small>Campeón</small>
                <strong>Argentina</strong>
              </div>
            </div>
          </div>
        </section>

        <section className="website-section" id="como-funciona">
          <div className="site-container">
            <div className="section-heading">
              <p className="eyebrow">La competencia</p>
              <h2>Todo el torneo en un solo lugar</h2>
              <p>
                Una herramienta clara para administrar la competencia y compartir su desarrollo
                públicamente.
              </p>
            </div>
            <div className="editorial-columns">
              <article>
                <span>01</span>
                <h3>Se sortea la llave</h3>
                <p>Los equipos quedan distribuidos al azar en cruces de eliminación directa.</p>
              </article>
              <article>
                <span>02</span>
                <h3>Se juegan los partidos</h3>
                <p>
                  Cada encuentro muestra su horario, marcador y definición por penales cuando
                  corresponde.
                </p>
              </article>
              <article>
                <span>03</span>
                <h3>Avanzan los ganadores</h3>
                <p>
                  La llave se completa automáticamente ronda a ronda hasta consagrar al campeón.
                </p>
              </article>
            </div>
          </div>
        </section>

        <section className="website-callout">
          <div className="site-container callout-inner">
            <div>
              <p className="eyebrow">La próxima copa</p>
              <h2>Descubrí quién sigue en carrera.</h2>
            </div>
            <Link className="primary-button" href="/torneos">
              Consultar competencias
            </Link>
          </div>
        </section>
      </main>
      <PublicFooter />
    </div>
  );
}
