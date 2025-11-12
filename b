Ventajas de esta arquitectura:

Más económica: Serverless vs EC2 24/7
Auto-escalable: Amplify y Lambda escalan automáticamente
Más simple: Menos infraestructura que mantener
CI/CD incluido: Push a GitHub → deploy automático
Cumple todos los requisitos

Lo que debes documentar:

Cómo Docusaurus (estático) consume la API de comentarios vía JavaScript
Rate limiting en generación de artículos (2 min puede ser agresivo)
Costos de Lambda ejecutándose 720 veces/día
CORS configuration entre Amplify y API Gateway

└── 📁 src/                         # React application (separado)
    ├── App.jsx
    ├── main.jsx
    ├── index.css
    ├── config.js
    ├── components/
    │   ├── Navbar.jsx
    │   └── Footer.jsx
    ├── pages/
    │   ├── Home.jsx
    │   ├── AIArticles.jsx
    │   └── Comentarios.jsx
    └── lib/
        ├── api.js
        ├── constants.js
        ├── utils.js
        └── validators.js