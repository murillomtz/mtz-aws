import React from "react";
import { Link } from "react-router-dom";
import DadosMurilloMtz from "./DadosMurilloMtz.jsx";

const About = () => {
  return (
    <div className="about-page">
      <div className="about-content">
        <div className="feature-grid">
          <div className="feature-card highlight">
            <h4>AWS & IA</h4>
          </div>
        </div>

        <DadosMurilloMtz />
      </div>

      <div className="about-footer">
        <Link to="/" className="back-button">
          ← Voltar
        </Link>
      </div>
    </div>
  );
};

export default About;
