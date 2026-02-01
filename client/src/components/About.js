import React from "react";
import { Link } from "react-router-dom";
import DadosMurilloMtz from "./DadosMurilloMtz";
const About = () => {
  return (
    <div>
      <h4>Versão 4.2.0</h4>
      <h5>MTZ 31/01 e 01/02/2026</h5>
      <Link to="/">Voltar</Link>
      <DadosMurilloMtz />
    </div>
  );
};

export default About;
