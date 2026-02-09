import React from 'react';
import './App.css';
import botLogo from './assets/bot_logo.png'; // Assuming this exists or I'll use a placeholder

function App() {
  return (
    <div className="App">
      <nav className="navbar">
        <div className="logo">
          <span className="logo-icon">🩺</span> HealthfyAI
          <img src={botLogo} alt="HealthfyAI Logo" className="nav-logo" style={{ display: 'none' }} />
        </div>
        <div className="nav-links">
          <a href="#features">Características</a>
          <a href="#download" className="btn-primary">Descargar App</a>
        </div>
      </nav>

      <header className="hero">
        <div className="hero-content">
          <span className="badge">Nueva Versión 1.0</span>
          <h1>Tu Asistente Médico Inteligente de Bolsillo</h1>
          <p>
            Diagnósticos preliminares instantáneos, análisis de lesiones de piel
            y un chat médico impulsado por IA disponible 24/7.
          </p>
          <div className="hero-buttons">
            <a href="#" className="btn-primary large">
              Descargar para Android
            </a>
            <a href="#" className="btn-secondary large">
              Ver Demo
            </a>
          </div>
          <div className="trust-badges">
            <span>🔒 100% Seguro</span>
            <span>⚡ Análisis en segundos</span>
            <span>🤖 IA Avanzada</span>
          </div>
        </div>
        <div className="hero-image">
          {/* Placeholder for App Screenshot */}
          <div className="phone-mockup">
            <div className="screen">
              <div className="app-header">HealthfyAI</div>
              <div className="chat-bubble left">Hola, ¿en qué puedo ayudarte hoy?</div>
              <div className="chat-bubble right">Tengo una mancha extraña en el brazo.</div>
              <div className="chat-bubble left">Por favor, sube una foto para analizarla.</div>
            </div>
          </div>
        </div>
      </header>

      <section id="features" className="features">
        <div className="section-header">
          <h2>Todo lo que necesitas para cuidar tu salud</h2>
          <p>Tecnología avanzada al servicio de tu bienestar</p>
        </div>

        <div className="features-grid">
          <div className="feature-card">
            <div className="icon">📸</div>
            <h3>Escaneo de Lesiones</h3>
            <p>Sube una foto de cualquier afección en la piel y obtén un pre-diagnóstico instantáneo con confianza del 95%.</p>
          </div>
          <div className="feature-card">
            <div className="icon">💬</div>
            <h3>Chat Médico IA</h3>
            <p>Conversa naturalmente con nuestro asistente para resolver dudas sobre síntomas, medicamentos y cuidados.</p>
          </div>
          <div className="feature-card">
            <div className="icon">📁</div>
            <h3>Historial Seguro</h3>
            <p>Mantén un registro privado y seguro de todos tus análisis y conversaciones para futuras referencias.</p>
          </div>
          <div className="feature-card">
            <div className="icon">🌙</div>
            <h3>Modo Oscuro</h3>
            <p>Interfaz cómoda y adaptable a cualquier condición de luz, pensada para tu descanso visual.</p>
          </div>
        </div>
      </section>

      <section className="cta-section" id="download">
        <div className="cta-content">
          <h2>Empieza a cuidar tu salud hoy mismo</h2>
          <p>Únete a miles de usuarios que ya confían en HealthfyAI.</p>
          <a href="#" className="btn-white large">Descargar Ahora (Gratis)</a>
        </div>
      </section>

      <footer className="footer">
        <div className="footer-content">
          <div className="footer-logo">HealthfyAI</div>
          <div className="footer-links">
            <a href="#">Privacidad</a>
            <a href="#">Términos</a>
            <a href="#">Contacto</a>
          </div>
        </div>
        <div className="footer-bottom">
          &copy; {new Date().getFullYear()} HealthfyAI. Todos los derechos reservados.
        </div>
      </footer>
    </div>
  );
}

export default App;
