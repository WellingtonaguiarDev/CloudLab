import { useEffect, useState } from "react";

// Base da API. Em produção o nginx injeta window.__API_URL__ a partir de
// API_URL (config.js gerado no start do container). Fallback: caminho relativo.
const API_BASE = window.__API_URL__ || "/api";

export default function App() {
  const [status, setStatus] = useState("carregando...");
  const [items, setItems] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch(`${API_BASE}/items`)
      .then((r) => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        return r.json();
      })
      .then((data) => {
        setItems(data.items || []);
        setStatus(`ok (fonte: ${data.source})`);
      })
      .catch((err) => {
        setError(err.message);
        setStatus("erro");
      });
  }, []);

  return (
    <main className="container">
      <header>
        <h1>CloudLab</h1>
        <p className="subtitle">Frontend React servido por nginx</p>
      </header>

      <section className="card">
        <h2>Status da API</h2>
        <p className={error ? "status error" : "status ok"}>{status}</p>
        {error && <p className="error-detail">{error}</p>}
      </section>

      <section className="card">
        <h2>Itens</h2>
        {items.length === 0 ? (
          <p>Nenhum item.</p>
        ) : (
          <ul>
            {items.map((it) => (
              <li key={it.id}>
                #{it.id} — {it.name}
              </li>
            ))}
          </ul>
        )}
      </section>

      <footer>
        <small>API: {API_BASE}</small>
      </footer>
    </main>
  );
}
