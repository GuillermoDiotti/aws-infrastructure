# 🚀 AWS Cloud Infrastructure - Obligatorio 2

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![React](https://img.shields.io/badge/React-19.1.1-61DAFB?logo=react&logoColor=white)](https://reactjs.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Sistema completo de gestión de contenido con IA generativa, desplegado en AWS mediante Infrastructure as Code (Terraform)**

Universidad ORT Uruguay | Infraestructura en la Nube | 2025

---

## 📋 Tabla de Contenidos

- [Visión General](#-visión-general)
- [Características Principales](#-características-principales)
- [Arquitectura](#-arquitectura)
- [Stack Tecnológico](#-stack-tecnológico)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Prerequisitos](#-prerequisitos)
- [Instalación y Despliegue](#-instalación-y-despliegue)
- [Configuración](#-configuración)
- [Módulos de Infraestructura](#-módulos-de-infraestructura)
- [Endpoints de API](#-endpoints-de-api)
- [Monitoreo y Logs](#-monitoreo-y-logs)
- [Seguridad](#-seguridad)
- [Costos Estimados](#-costos-estimados)
- [Troubleshooting](#-troubleshooting)
- [Contribución](#-contribución)
- [Licencia](#-licencia)

---

## 🎯 Visión General

Este proyecto implementa una **arquitectura cloud-native serverless completa** en AWS, utilizando Terraform para la gestión de infraestructura. El sistema incluye:

- 🤖 **Generación automática de artículos** con IA (AWS Bedrock - Llama 3.1)
- 💬 **Sistema de comentarios** con persistencia en RDS PostgreSQL
- 📱 **Frontend React** moderno desplegado con AWS Amplify
- 🔔 **Notificaciones en tiempo real** vía SNS
- 📊 **Logging centralizado** con CloudWatch
- 🌐 **CDN global** con CloudFront
- 🏛️ **Sitio institucional estático** con S3 + CloudFront

### Arquitectura Simplificada Cloud-Native

```
┌────────────────────────────────────────────────────────────────┐
│                         USUARIOS                               │
└────────────┬─────────────────────────┬─────────────────────────┘
             │                         │
             │                         │
    ┌────────▼────────┐        ┌───────▼──────────┐
    │  AWS Amplify    │        │   CloudFront     │
    │  (React App)    │        │  (Static Site)   │
    └────────┬────────┘        └───────┬──────────┘
             │                         │
             │                         │
    ┌────────▼─────────────────────────▼──────────┐
    │            API Gateway (REST)               │
    └────────┬─────────────────────────┬──────────┘
             │                         │
    ┌────────▼────────┐        ┌───────▼──────────┐
    │  Lambda         │        │  Lambda          │
    │  (Artículos)    │        │  (Comentarios)   │
    └────────┬────────┘        └───────┬──────────┘
             │                         │
    ┌────────▼────────┐        ┌───────▼──────────┐
    │   DynamoDB      │        │  RDS PostgreSQL  │
    │   (Articles)    │        │  (Comments)      │
    └─────────────────┘        └──────────────────┘
             │
    ┌────────▼────────┐
    │  EventBridge    │
    │  (Scheduler)    │
    └─────────────────┘
             │
    ┌────────▼────────┐
    │  AWS Bedrock    │
    │  (Llama 3.1)    │
    └─────────────────┘
```

---

## ✨ Características Principales

### 🤖 Generación de Artículos con IA

- **AWS Bedrock (Llama 3.1 8B)** para generación de contenido
- **Scheduler automático** vía EventBridge (por defecto cada 15 minutos)
- **Contenidos de los archivos dinámicos**: IA, Business, Finance, ML, Blockchain, etc.
- **Persistencia en DynamoDB** con TTL de 30 días
- **Metadata enriquecida**: word count, model info, timestamps

### 💬 Sistema de Comentarios

- **Base de datos relacional** RDS PostgreSQL en VPC privada
- **Validación de datos** en backend y frontend para mayor seguridad
- **Almacenamiento seguro** con cifrado
- **API RESTful** para CRUD operations

### 🔔 Notificaciones Inteligentes

- **SNS Topics** separados para artículos y comentarios
- **Email notifications** automáticas
- **Formato profesional** con metadata completa

### 📊 Observabilidad

- **CloudWatch Logs** centralizados para todos los servicios
- **CloudWatch Alarms** para errores, throttles y latencia
- **VPC Flow Logs** para análisis de tráfico
- **CloudTrail** para auditoría de acciones
- **Budget Alarms** para mayor control del presupuesto

### 🔒 Seguridad

- **VPC aislada** con subnets públicas y privadas
- **Security Groups** restrictivos por servicio
- **NAT Gateway** para acceso controlado a internet
- **Secrets Manager** para credenciales
- **IAM Roles** siguiendo el principio de mínimo privilegio
- **Cifrado en tránsito y reposo**

---

## 🏗️ Arquitectura

### Componentes Principales

#### Frontend Layer
- **AWS Amplify**: Hosting de aplicación React con CI/CD automático
- **CloudFront**: CDN para sitio estático institucional
- **S3**: Almacenamiento de assets estáticos

#### API Layer
- **API Gateway REST**: Endpoint único para todas las operaciones
- **CORS configurado** para acceso desde Amplify

#### Compute Layer
- **Lambda Functions** (Python 3.12):
  - `generate_article`: Genera artículos con Bedrock
  - `get_article`: Lista y obtiene artículos de DynamoDB
  - `create_comentario`: Crea comentarios en RDS
  - `get_comentarios`: Lista comentarios desde RDS

#### Data Layer
- **DynamoDB**: Almacenamiento NoSQL para artículos
  - GSI: `CreatedAtIndex` (por fecha)
  - GSI: `TopicIndex` (por tema + fecha)
- **RDS PostgreSQL**: Base de datos relacional para comentarios
  - Multi-AZ para alta disponibilidad
  - Backups automáticos

#### Networking Layer
- **VPC** con CIDR `10.0.0.0/16`
  - Public Subnet: `10.0.1.0/24` (NAT Gateway)
  - Private Subnet 1: `10.0.2.0/24` (Lambdas)
  - Private Subnet 2: `10.0.3.0/24` (RDS)
- **Internet Gateway** para conectividad externa
- **NAT Gateway** para salida de Lambdas

#### Automation Layer
- **EventBridge**: Scheduler para generación automática de artículos
- **SNS**: Notificaciones por email

---

## 🛠️ Stack Tecnológico

### Infrastructure as Code
- **Terraform 1.0+**: Gestión declarativa de infraestructura
- **Módulos reutilizables**

### Cloud Provider
- **AWS**: 20+ servicios integrados

### Frontend
- **React 19.1.1**: Framework UI
- **Vite 7.1**: Build tool ultrarrápido
- **React Router 7.9**: Client-side routing
- **React Markdown 10.1**: Renderizado de contenido

### Backend
- **Python 3.12**: Runtime para Lambdas
- **psycopg2-binary**: PostgreSQL adapter
- **boto3**: AWS SDK

### AI/ML
- **AWS Bedrock**: Servicio de IA gestionado
- **Meta Llama 3.1 8B**: Modelo de lenguaje

### Databases
- **Amazon DynamoDB**: NoSQL serverless
- **Amazon RDS PostgreSQL 15.8**: Base de datos relacional

### DevOps
- **AWS Amplify**: CI/CD para frontend

---

## 📁 Estructura del Proyecto

```
aws-infrastructure/
├── 📄 main.tf                      # Orquestación principal
├── 📄 providers.tf                 # Configuración de providers
├── 📄 variables.tf                 # Variables globales
├── 📄 outputs.tf                   # Outputs del proyecto
├── 📄 data.tf                      # Data sources
├── 📄 .terraform.lock.hcl          # Lock de versiones
├── 📄 terraform.tfvars.example     # Template de variables de configuración de terrform
├── 📄 .env.example                 # Template de variables de configuración de entorno
├── 📄 amplify.yml                  # Build spec para Amplify
|
├── 📄 fronted_config.sh            # Bash para el envío del endpoint de la api gateway al front end
├── 📄 user_cli.sh                  # Bash para la creación del usuario encargado de la AWS Cli
├── 📄 .gitignore                   # Archivo gitignore
│
├── 📁 modules/                     # Módulos de Terraform
│   │
│   ├── 📁 amplify/                 # Frontend deployment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 api_gateway/             # REST API
│   │   ├── main.tf                 # Resources, methods, integrations
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 lambda_articulos/        # Lambda para artículos
│   │   ├── main.tf
│   │   ├── data.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── 📁 functions/
│   │       ├── 📁 py/
│   │       │   ├── 📁 generate_article/
│   │       │   │   ├── index.py
│   │       │   │   ├── constants.py
│   │       │   │   └── prompt.py
│   │       │   └── 📁 get_article/
│   │       │       └── index.py
│   │       └── 📁 zip/
│   │
│   ├── 📁 lambda_comentarios/      # Lambda para comentarios
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── create_psycopg2_layer.sh
│   │   ├── 📁 layers/
│   │   │   └── psycopg2-layer.zip
│   │   └── 📁 functions/
│   │       ├── 📁 py/
│   │       │   ├── 📁 create_comentario/
│   │       │   │   └── index.py
│   │       │   └── 📁 get_comentarios/
│   │       │       └── index.py
│   │       └── 📁 zip/
│   │
│   ├── 📁 dynamodb/                # NoSQL database
│   │   ├── main.tf                 # Table + GSIs
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 rds/                     # PostgreSQL database
│   │   ├── main.tf                 # Instance, subnet group, SG
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 networking/              # VPC infrastructure
│   │   ├── main.tf                 # VPC, subnets, IGW, NAT, routes
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 eventbridge/             # Scheduler
│   │   ├── main.tf                 # Rules + targets
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 secrets_manager/         # Credentials storage
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 iam/                     # Roles and policies
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 sns/                     # Notifications
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 cloudwatch_logging/      # Centralized logs
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 cloudwatch_alarms/       # Monitoring alarms
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 cloudtrail_logging/      # Audit logs
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── 📁 static_site/             # S3 + CloudFront
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── 📁 budget/                  # Cost management
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── 📁 static_page/                 # Sitio institucional
│   └── index.html
│
└── 📁 user-policies/               # Políticas de mínimo privilegio para AWS Cli
    ├── TerraformAPIPolicy.json
    ├── TerraformBillingPolicy.json
    ├── TerraformComputePolicy.json
    ├── TerraformDatabasePolicy.json
    ├── TerraformNetworkingPolicy.json
    ├── TerraformMessagingPolicy.json
    ├── TerraformStoragePolicy.json
    ├── TerraformMonitoringPolicy.json
    └── TerraformSecurityPolicy.json

```

---

## Primeros pasos

### 📋 Software Requerido

```bash
# Terraform
terraform --version
# Terraform v1.0.0 o superior

# AWS CLI
aws --version
# aws-cli/2.x.x o superior

# Node.js (para frontend)
node --version
# v20.x o superior

# Python (para Lambdas)
python3 --version
# Python 3.12
```

### GitHub Personal Access Token

Para Amplify, necesitas un token con permisos:
- `repo` (acceso completo a repositorios)
- `admin:repo_hook` (administrar webhooks)

Genera uno en: https://github.com/settings/tokens

---

## 🚀 Instalación y Despliegue

### 1. Clonar el Repositorio

```bash
git clone https://github.com/tu-usuario/aws-infrastructure.git
cd aws-infrastructure
```

### 2. Configuración de Credenciales IAM AWS

**user-cli.sh** crea el user para AWS Cli con permisos de minimo privilegio

```bash
# Permisos de ejecución
chmod +x user-cli.sh

# Ejecución
./ user-cli.sh
# NOTA: Guardar las credenciales retornadas para el la configuración del IAM User en el siguiente paso

# Configurar AWS CLI
aws configure --profile terraform-cli

# Asignar como usuario predeterminado (OPCIONAL)
export AWS_PROFILE=terraform-cli

# Verificar credenciales
aws sts get-caller-identity
```

### 2. Configurar Variables de Entorno y de Terraform

```bash
# Copiar template
cp terraform.tfvars.example terraform.tfvars

# Editar con tus valores
nano terraform.tfvars

# Copiar template
cp .env.example .env

# Editar con tus valores
nano .env
```

### 3. Crear Layer de psycopg2 (PostgreSQL)

```bash
cd modules/lambda_comentarios
chmod +x create_psycopg2_layer.sh
./create_psycopg2_layer.sh
cd ../..
```

**Salida esperada:**
```
🔨 Building psycopg2 Lambda Layer (Python 3.12)
================================================
✅ psycopg2 directory found
✅ Layer created successfully!
📦 Size: 3.2M
```

### 4. Inicializar Terraform

```bash
terraform init
```

**Salida esperada:**
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...

Terraform has been successfully initialized!
```

### 5. Validar Configuración

```bash
# Validar sintaxis
terraform validate

# Ver plan de ejecución
terraform plan
```

### 6. Desplegar Infraestructura

```bash
terraform apply
```

**Confirmar con `yes` cuando se solicite.**

⏱️ **Tiempo estimado**: 15-20 minutos

### 7. Confirmar Suscripción SNS

Después del despliegue, recibirás **2 emails** de AWS SNS:

1. Notificaciones de artículos
2. Notificaciones de comentarios

**Haz clic en "Confirm subscription"** en ambos emails.

### 8. Verificar Despliegue

```bash
# Obtener URL de la aplicación
terraform output deployment_summary

# Verificar API Gateway
terraform output api_endpoint

# Verificar sitio institucional
terraform output institutional_site_url
```

---

## ⚙️ Configuración

### Variables de Entorno - Frontend (React)

Archivo: `frontend_config.sh`

```bash
# Permisos de ejecución
chmod +x user-cli.sh

# Ejecución
./ user-cli.sh
```

**Se envía el endpoint de la API Gateway al Repositorio del Front-End. Al detectar cambios, Amplify comienzo a contruir la aplicación**

**Tiempo Estimado: 5 minutos**

---

## 🧩 Módulos de Infraestructura

### 1. **Amplify** - Frontend Deployment

**Propósito**: Hosting y CI/CD para React app

**Recursos creados**:
- `aws_amplify_app`
- `aws_amplify_branch`
- `aws_amplify_webhook`
- `aws_iam_role` (Amplify service role)

**Features**:
- Build automático en cada push a `main`
- Node.js 20 configurado
- Custom rules para React Router (SPA)

### Configuración de Amplify

Archivo: `amplify.yml`

```yaml
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - nvm install 20
        - nvm use 20
        - npm ci --legacy-peer-deps
    build:
      commands:
        - npx vite build
  artifacts:
    baseDirectory: dist
    files:
      - "**/*"
  cache:
    paths:
      - node_modules/**/*
```

---

### 2. **Networking** - VPC Infrastructure

**Propósito**: Red aislada y segura

**Recursos creados**:
- 1 VPC
- 3 Subnets (1 pública, 2 privadas)
- 1 Internet Gateway
- 1 NAT Gateway
- 3 Route Tables
- Security Groups
- VPC Flow Logs

**Diagrama de red**:
```
┌─────────────────── VPC 10.0.0.0/16 ──────────────────┐
│                                                      │
│  ┌─── Public Subnet (10.0.1.0/24) ───┐               │
│  │   - NAT Gateway                   │               │
│  │   - Internet Gateway              │               │
│  └───────────────────────────────────┘               │
│                                                      │
│  ┌─── Private Subnet 1 (10.0.2.0/24) ──┐             │
│  │   - Lambda Functions                │             │
│  └─────────────────────────────────────┘             │
│                                                      │
│  ┌─── Private Subnet 2 (10.0.3.0/24) ──┐             │
│  │   - RDS PostgreSQL                  │             │
│  └─────────────────────────────────────┘             │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

### 3. **API Gateway** - REST API

**Propósito**: Punto de entrada único para todas las operaciones

**Endpoints configurados**:

| Método | Path              | Lambda Target       | Descripción                    |
|--------|-------------------|---------------------|--------------------------------|
| GET    | /articles         | get_article         | Lista todos los artículos      |
| GET    | /articles/{id}    | get_article         | Obtiene artículo por ID        |
| POST   | /articles         | generate_article    | Genera nuevo artículo (manual) |
| GET    | /comentarios      | get_comentarios     | Lista comentarios              |
| POST   | /comentarios      | create_comentario   | Crea nuevo comentario          |

**CORS habilitado** para todos los endpoints.

---

### 4. **Lambda Artículos** - AI Content Generation

**Funciones**:

#### `generate_article`
- **Runtime**: Python 3.12
- **Timeout**: 120s
- **Memory**: 512 MB
- **Triggers**: EventBridge + API Gateway
- **Acciones**:
  1. Selecciona tema aleatorio
  2. Llama a Bedrock (Llama 3.1)
  3. Procesa respuesta
  4. Guarda en DynamoDB
  5. Envía notificación SNS

#### `get_article`
- **Runtime**: Python 3.12
- **Timeout**: 30s
- **Memory**: 256 MB
- **Triggers**: API Gateway
- **Acciones**:
  1. Query a DynamoDB
  2. Ordena por fecha
  3. Devuelve JSON

---

### 5. **Lambda Comentarios** - Comments Management

**Funciones**:

#### `create_comentario`
- **Runtime**: Python 3.12
- **Timeout**: 60s
- **Memory**: 512 MB
- **Layer**: psycopg2-binary
- **Acciones**:
  1. Valida input
  2. Conecta a RDS
  3. INSERT en PostgreSQL
  4. Envía notificación SNS

#### `get_comentarios`
- **Runtime**: Python 3.12
- **Timeout**: 60s
- **Memory**: 512 MB
- **Layer**: psycopg2-binary
- **Acciones**:
  1. Conecta a RDS
  2. SELECT últimos 50 comentarios
  3. Ordena por fecha DESC

---

### 6. **DynamoDB** - NoSQL Database

**Configuración**:
- **Billing Mode**: PAY_PER_REQUEST (on-demand)
- **Primary Key**: `id` (String - UUID)
- **TTL**: 30 días (atributo `ttl`)

**Global Secondary Indexes**:
1. **CreatedAtIndex**: Query por fecha de creación
2. **TopicIndex**: Query por tema + fecha

**Estructura de Item**:
```json
{
  "id": "uuid-v4",
  "title": "Título del artículo",
  "content": "Contenido markdown...",
  "topic": "technology",
  "style": "informative",
  "length": "medium",
  "created_at": "2025-01-10T12:00:00Z",
  "ttl": 1738675200,
  "source": "eventbridge",
  "metadata": {
    "word_count": 456,
    "char_count": 2890,
    "model": "llama3-1-8b",
    "generated_by": "bedrock",
    "temperature": 0.7
  }
}
```

---

### 7. **RDS** - PostgreSQL Database

**Configuración**:
- **Engine**: PostgreSQL 15.8
- **Instance Class**: db.t3.micro
- **Storage**: 20 GB gp3 (encrypted)
- **Multi-AZ**: No (dev environment)
- **Backup**: 7 días de retención

**Tabla `comentarios`**:
```sql
CREATE TABLE comentarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    comentario TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_comentarios_created_at
ON comentarios(created_at DESC);
```

**Seguridad**:
- En VPC privada (no accesible desde internet)
- Security Group solo permite conexiones desde Lambdas
- Credenciales en Secrets Manager

---

### 8. **EventBridge** - Scheduler

**Propósito**: Automatización de generación de artículos

**Configuración**:
```hcl
schedule_expression = "rate(15 minutes)"
```

**Payload enviado a Lambda**:
```json
{
  "topic": "technology",
  "style": "informative",
  "length": "medium",
  "source": "eventbridge"
}
```

Por defecto: **cada 15 minutos**

Para cambiar:

```hcl
# terraform.tfvars
TF_VAR_article_generation_schedule = "rate(30 minutes)"
# o
TF_VAR_article_generation_schedule = "cron(0 12 * * ? *)" # Diario a las 12:00 UTC
```

Después de cambiar:
```bash
terraform apply -var="article_generation_schedule=rate(30 minutes)"
```

---

### 9. **Secrets Manager** - Credentials Storage

**Secrets creados**:

1. **Bedrock Config**: `/proyecto/bedrock/config`
```json
{
  "model_id": "us.meta.llama3-1-8b-instruct-v1:0",
  "temperature": 0.7,
  "max_tokens": 2000,
  "anthropic_version": "bedrock-2023-05-31"
}
```

2. **RDS Credentials**: `/proyecto/rds/credentials`
```json
{
  "username": "dbadmin",
  "password": "<auto-generated>",
  "engine": "postgres",
  "host": "proyecto-postgres.xxxxx.us-east-1.rds.amazonaws.com",
  "port": 5432,
  "dbname": "comentarios_db"
}
```

---

### 10. **SNS** - Notifications

**Topics creados**:

1. **article_notifications**: Notifica cuando se genera un artículo
2. **comment_notifications**: Notifica cuando se publica un comentario

**Formato de mensaje (artículo)**:
```
===========================================================
             🤖 NUEVO ARTÍCULO GENERADO POR IA
===========================================================

📌 TÍTULO:
El Futuro de la Inteligencia Artificial

📊 INFORMACIÓN:
• ID: abc123-def456-...
• Tema: technology
• Estilo: informative
• Longitud: medium
• Palabras: 456
• Fecha: 2025-01-10T12:00:00Z
• Fuente: eventbridge

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Este artículo fue generado automáticamente por el sistema de IA.
Modelo: llama3-1-8b
Temperatura: 0.7
```

---

### 11. **CloudWatch Logging** - Centralized Logs

**Log Groups creados**:
- `/aws/lambda/proyecto-generate-article`
- `/aws/lambda/proyecto-get-article`
- `/aws/lambda/proyecto-create-comentario`
- `/aws/lambda/proyecto-get-comentarios`
- `/aws/apigateway/proyecto-articles-api`
- `/aws/amplify/proyecto-app`
- `/aws/rds/instance/proyecto-postgres/postgresql`
- `/aws/events/proyecto-schedule`
- `/aws/vpc/proyecto-flow-logs`
- `/aws/cloudtrail/proyecto`

**Retención**: 7 días (configurable)

---

### 12. **CloudWatch Alarms** - Monitoring

**Alarmas configuradas por Lambda**:

1. **Errores**: > 5 errores en 5 minutos
2. **Throttles**: > 10 throttles en 5 minutos
3. **Duration**: Promedio > 10 segundos

**Notificaciones**: Via SNS al email configurado

---

### 13. **CloudTrail** - Audit Logging

**Propósito**: Auditoría completa de acciones en AWS

**Eventos capturados**:
- Management events (IAM, DynamoDB admin, SNS admin)
- Data events de DynamoDB (PutItem, GetItem, etc.)

**Almacenamiento**:
- S3 bucket: `proyecto-cloudtrail-logs`
- CloudWatch Logs: `/aws/cloudtrail/proyecto`

---

### 14. **Budget** - Cost Management

**Configuración**:
- Límite mensual: $50 USD (configurable)
- Notificaciones:
  - 80% del presupuesto (ACTUAL)
  - 100% del presupuesto (ACTUAL)
  - 90% del presupuesto (FORECASTED)

---

## 🌐 Endpoints de API

### Base URL

```
https://{api-id}.execute-api.us-east-1.amazonaws.com/prod
```

Obtener con:
```bash
# Endpoint de la API Gateway
terraform output api_endpoint
```

---

### Artículos

#### Lista todos los artículos

```http
GET /articles
```

**Query Parameters** (opcionales):
- `limit`: Máximo de artículos a devolver (default: 50, max: 100)
- `lastKey`: Token de paginación

**Response** (200 OK):
```json
{
  "success": true,
  "items": [
    {
      "id": "abc-123",
      "title": "El Futuro de la IA",
      "content": "# El Futuro de la IA\n\n...",
      "topic": "technology",
      "style": "informative",
      "length": "medium",
      "created_at": "2025-01-10T12:00:00Z",
      "ttl": 1738675200,
      "metadata": {
        "word_count": 456,
        "model": "llama3-1-8b"
      }
    }
  ],
  "count": 1,
  "lastKey": "xyz-789"
}
```

---

#### Obtiene un artículo específico

```http
GET /articles/{id}
```

**Path Parameters**:
- `id`: UUID del artículo

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "abc-123",
    "title": "El Futuro de la IA",
    "content": "# El Futuro de la IA\n\n...",
    "topic": "technology",
    "created_at": "2025-01-10T12:00:00Z"
  }
}
```

**Response** (404 Not Found):
```json
{
  "success": false,
  "error": "Article not found",
  "article_id": "abc-123"
}
```

---

#### Genera un artículo manualmente

```http
POST /articles
```

**Body** (opcional):
```json
{
  "topic": "artificial intelligence",
  "style": "technical",
  "length": "long"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "article_id": "new-uuid",
  "title": "Advanced AI Architectures",
  "topic": "artificial intelligence",
  "created_at": "2025-01-10T13:30:00Z",
  "word_count": 823,
  "message": "Article generated successfully"
}
```

---

### Comentarios

#### Lista todos los comentarios

```http
GET /comentarios
```

**Response** (200 OK):
```json
{
  "success": true,
  "items": [
    {
      "id": 42,
      "nombre": "Juan Pérez",
      "email": "juan@example.com",
      "comentario": "Excelente artículo sobre IA!",
      "created_at": 1704902400000
    }
  ],
  "count": 1
}
```

---

#### Crea un nuevo comentario

```http
POST /comentarios
Content-Type: application/json
```

**Body**:
```json
{
  "nombre": "María González",
  "email": "maria@example.com",
  "comentario": "Muy interesante el análisis sobre blockchain"
}
```

**Validaciones**:
- `nombre`: 2-100 caracteres
- `email`: Formato válido
- `comentario`: 10-1000 caracteres

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "id": 43,
    "nombre": "María González",
    "email": "maria@example.com",
    "comentario": "Muy interesante el análisis sobre blockchain",
    "created_at": 1704902500000
  },
  "message": "Comentario creado exitosamente"
}
```

**Response** (400 Bad Request):
```json
{
  "success": false,
  "errors": [
    "Nombre debe tener al menos 2 caracteres",
    "Email inválido"
  ]
}
```

---

## 📊 Monitoreo y Logs

### CloudWatch Logs

#### Ver logs de Lambda en tiempo real

```bash
# Generate Article
aws logs tail /aws/lambda/proyecto-generate-article --follow

# Get Article
aws logs tail /aws/lambda/proyecto-get-article --follow

# Create Comentario
aws logs tail /aws/lambda/proyecto-create-comentario --follow

# Get Comentarios
aws logs tail /aws/lambda/proyecto-get-comentarios --follow
```

#### Ver logs de API Gateway

```bash
aws logs tail /aws/apigateway/proyecto-articles-api --follow
```

#### Buscar errores en logs

```bash
aws logs filter-log-events \
  --log-group-name /aws/lambda/proyecto-generate-article \
  --filter-pattern "ERROR" \
  --start-time $(date -u -d '1 hour ago' +%s)000
```

---

### CloudWatch Metrics

#### Invocaciones de Lambda (últimas 24h)

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=proyecto-generate-article \
  --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum
```

#### Errores de Lambda

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=proyecto-generate-article \
  --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum
```

---

### CloudWatch Alarms

#### Listar alarmas activas

```bash
aws cloudwatch describe-alarms \
  --state-value ALARM \
  --query 'MetricAlarms[*].[AlarmName,StateValue,StateReason]' \
  --output table
```

#### Dashboard de monitoreo

Acceder a CloudWatch Console:
```
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:
```

**Métricas recomendadas para dashboard**:
1. Lambda Invocations (todas las funciones)
2. Lambda Errors (todas las funciones)
3. Lambda Duration (p50, p90, p99)
4. API Gateway 4XX/5XX Errors
5. API Gateway Latency
6. DynamoDB Consumed Read/Write Capacity
7. RDS CPU Utilization
8. RDS DatabaseConnections

---

### VPC Flow Logs

#### Ver tráfico de red

```bash
aws logs tail /aws/vpc/proyecto-flow-logs --follow
```

#### Analizar conexiones rechazadas

```bash
aws logs filter-log-events \
  --log-group-name /aws/vpc/proyecto-flow-logs \
  --filter-pattern "[version, account, eni, source, destination, srcport, dstport, protocol, packets, bytes, windowstart, windowend, action=REJECT, flowlogstatus]" \
  --max-items 50
```

---

### CloudTrail

#### Ver eventos recientes

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceType,AttributeValue=AWS::DynamoDB::Table \
  --max-items 10
```

#### Exportar eventos a JSON

```bash
aws cloudtrail lookup-events \
  --start-time $(date -u -d '1 day ago' +%Y-%m-%dT%H:%M:%S) \
  --query 'Events[*].[CloudTrailEvent]' \
  --output json > cloudtrail-events.json
```

---

## 🔒 Seguridad

### Principio de Mínimo Privilegio

Todos los roles IAM siguen el principio de mínimo privilegio:

#### Lambda Role - Permisos

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/aws/lambda/proyecto-*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": [
        "arn:aws:dynamodb:*:*:table/proyecto-ai-articulos",
        "arn:aws:dynamodb:*:*:table/proyecto-ai-articulos/index/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel"
      ],
      "Resource": "arn:aws:bedrock:*::foundation-model/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:*:*:secret:proyecto/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": "arn:aws:sns:*:*:proyecto-*"
    }
  ]
}
```

---

### Security Groups

#### Lambda Security Group

```hcl
resource "aws_security_group" "lambda" {
  name        = "proyecto-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id

  # Solo egress permitido
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}
```

#### RDS Security Group

```hcl
resource "aws_security_group" "rds" {
  name        = "proyecto-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  # Solo acepta conexiones desde Lambdas
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
    description     = "PostgreSQL from Lambda"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

### Secrets Manager - Rotación Automática

Para habilitar rotación de contraseñas RDS:

```bash
# Crear función Lambda para rotación
aws secretsmanager rotate-secret \
  --secret-id proyecto/rds/credentials \
  --rotation-lambda-arn arn:aws:lambda:us-east-1:ACCOUNT_ID:function:SecretsManagerRotation \
  --rotation-rules AutomaticallyAfterDays=30
```

---

### WAF (Opcional - Mejora)

Para agregar Web Application Firewall a API Gateway:

```hcl
# modules/api_gateway/main.tf - Agregar

resource "aws_wafv2_web_acl" "api_gateway" {
  name  = "${var.project_name}-api-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "APIGatewayWAF"
    sampled_requests_enabled   = true
  }
}
```

---

## 💰 Costos Estimados

### Costo Mensual Aproximado (AWS Free Tier Considerado)

| Servicio | Uso Estimado | Costo/Mes (USD) | Notas |
|----------|--------------|-----------------|-------|
| **Lambda** | 720 ejecuciones/día<br>~21,600/mes | $0.00 | Dentro de Free Tier<br>(1M requests/mes) |
| **DynamoDB** | PAY_PER_REQUEST<br>~50K reads<br>~1K writes | $0.31 | Estimado bajo |
| **RDS t3.micro** | 730 horas/mes | $12.41 | db.t3.micro (750h Free Tier primer año) |
| **NAT Gateway** | 730 horas + 10GB | $33.48 | $0.045/hora + $0.045/GB |
| **API Gateway** | 100K requests | $0.35 | Primer 1M Free Tier |
| **Amplify** | 1 app | $0.00 | Build minutes incluidos |
| **CloudFront** | 10GB transferencia | $0.00 | Dentro de Free Tier |
| **S3** | 1GB storage | $0.02 | Primer 5GB Free Tier |
| **Secrets Manager** | 2 secretos | $0.80 | $0.40/secret/mes |
| **CloudWatch Logs** | 5GB logs/mes | $2.52 | $0.50/GB ingestion |
| **SNS** | 1K notificaciones | $0.00 | Primer 1M Free Tier |
| **EventBridge** | 21,600 eventos | $0.00 | Primer 1M Free Tier |
| **CloudTrail** | 1 trail | $0.00 | Primer trail gratis |
| **VPC** | Flow Logs 5GB | $2.52 | Logs storage |
| **Bedrock** | ~700 invocations<br>~500K tokens/mes | $0.00 - $5.00 | Depende del modelo |
| | | | |
| **TOTAL MENSUAL** | | **~$52 - $57** | Sin Free Tier: ~$65-70 |

### Optimizaciones de Costos

#### 1. Reducir costos del NAT Gateway (-$33.48/mes)

**Opción A**: Usar VPC Endpoints (recomendado)
```hcl
# modules/networking/main.tf - Agregar

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.dynamodb"
  route_table_ids = [aws_route_table.private.id]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.s3"
  route_table_ids = [aws_route_table.private.id]
}
```

**Ahorro**: ~$33/mes (eliminar NAT Gateway)

---

#### 2. Reducir costos de RDS (-$12.41/mes)

**Opción B**: Usar DynamoDB para comentarios en lugar de RDS
- Pro: Más barato, más escalable
- Contra: Requiere refactorización

---

#### 3. Reducir frecuencia de generación de artículos

```hcl
# terraform.tfvars
TF_VAR_article_generation_schedule = "rate(60 minutes)"  # En lugar de 15 min
```

**Ahorro**: Reduce invocaciones de Lambda y costos de Bedrock

---

#### 4. Optimizar retención de logs

```hcl
# Cambiar de 7 días a 3 días
log_retention_days = 3
```

**Ahorro**: ~$1-2/mes en almacenamiento

---

### Budget Alerts

El módulo `budget` ya está configurado para enviar alertas:

- ⚠️ **80% del presupuesto**: Warning email
- 🚨 **100% del presupuesto**: Critical email
- 📊 **90% forecast**: Predictive alert

Para cambiar el límite:
```hcl
# terraform.tfvars
TF_VAR_monthly_budget_limit = 30  # USD
```

---

## 🔧 Troubleshooting

### Problema: Amplify build falla

**Síntomas**:
```
npm ERR! code ERESOLVE
npm ERR! ERESOLVE could not resolve
```

**Solución**:
```yaml
# amplify.yml - Cambiar npm ci por:
- npm install --legacy-peer-deps
```

---

### Problema: Lambda no puede conectarse a RDS

**Síntomas**:
```
psycopg2.OperationalError: could not connect to server: Connection timed out
```

**Diagnóstico**:
1. Verificar Security Groups:
```bash
aws ec2 describe-security-groups \
  --group-ids sg-lambda-id sg-rds-id \
  --query 'SecurityGroups[*].[GroupId,GroupName,IpPermissions]'
```

2. Verificar que Lambda esté en VPC correcta:
```bash
aws lambda get-function-configuration \
  --function-name proyecto-create-comentario \
  --query 'VpcConfig'
```

**Solución**:
```bash
# Recrear recursos de networking
terraform destroy -target=module.networking
terraform apply -target=module.networking
terraform apply
```

---

### Problema: psycopg2 layer no funciona

**Síntomas**:
```
Unable to import module 'index': No module named 'psycopg2'
```

**Solución**:
```bash
cd modules/lambda_comentarios
rm -rf layers/psycopg2-layer.zip
./create_psycopg2_layer.sh
cd ../..
terraform apply -replace=module.lambda_comentarios.aws_lambda_layer_version.psycopg2
```

---

### Problema: Bedrock invocation falla

**Síntomas**:
```
botocore.exceptions.ClientError: An error occurred (AccessDeniedException)
when calling the InvokeModel operation
```

**Solución**:

1. Habilitar modelo en Bedrock Console:
```
https://console.aws.amazon.com/bedrock/home?region=us-east-1#/modelaccess
```

2. Solicitar acceso a Llama 3.1:
   - Seleccionar "Meta" → "Llama 3.1 8B Instruct"
   - Clic en "Request model access"
   - Esperar aprobación (~5 minutos)

---

### Problema: CORS errors en frontend

**Síntomas**:
```
Access to fetch at 'https://api...' from origin 'https://amplify...'
has been blocked by CORS policy
```

**Solución**:

Verificar que API Gateway tenga OPTIONS methods configurados:

```bash
terraform apply -replace=module.api_gateway.aws_api_gateway_deployment.main
```

---

### Problema: SNS notifications no llegan

**Síntomas**:
- No recibes emails después del despliegue

**Solución**:

1. Confirmar suscripción en email
2. Verificar spam folder
3. Re-suscribirse manualmente:

```bash
aws sns subscribe \
  --topic-arn $(terraform output -raw sns_topic_arn) \
  --protocol email \
  --notification-endpoint tu-email@example.com
```

---

### Problema: Terraform state lock

**Síntomas**:
```
Error: Error locking state: Error acquiring the state lock
```

**Solución**:
```bash
# Si el proceso anterior murió anormalmente
terraform force-unlock LOCK_ID

# Obtener LOCK_ID del mensaje de error
```

---

### Logs de debugging

#### Habilitar logs verbose en Lambda

```python
# index.py - Agregar al inicio
import logging
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
```

#### Habilitar X-Ray tracing

```hcl
# modules/lambda_articulos/main.tf - Agregar
resource "aws_lambda_function" "generate_article" {
  # ...

  tracing_config {
    mode = "Active"
  }
}
```

---

## 🤝 Contribución

### Guidelines

1. **Fork** el repositorio
2. **Crea una rama** para tu feature:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit** tus cambios:
   ```bash
   git commit -m "Add amazing feature"
   ```
4. **Push** a tu rama:
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Abre un Pull Request**

---

### Estructura de commits

Seguir [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add CloudFront distribution for static site
fix: resolve CORS issue in API Gateway
docs: update README with new endpoints
refactor: modularize Lambda functions
test: add integration tests for DynamoDB
chore: update Terraform to 1.7.0
```

---

### Testing local

#### Terraform validate

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

#### Lambda local testing (con SAM)

```bash
# Instalar AWS SAM CLI
brew install aws-sam-cli

# Invocar Lambda localmente
sam local invoke GenerateArticleFunction \
  --event events/generate-article-event.json
```

---

## 📚 Recursos Adicionales

### Documentación Oficial

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Lambda](https://docs.aws.amazon.com/lambda/)
- [AWS Bedrock](https://docs.aws.amazon.com/bedrock/)
- [AWS Amplify](https://docs.amplify.aws/)
- [React](https://react.dev/)

### Tutoriales Recomendados

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Serverless Architecture Patterns](https://www.serverless.com/blog/serverless-architecture-patterns)

### Comunidad

- [AWS Community Builders](https://aws.amazon.com/developer/community/community-builders/)
- [Terraform Registry](https://registry.terraform.io/)
- [r/aws](https://reddit.com/r/aws)
- [r/terraform](https://reddit.com/r/terraform)

---

## 📄 Licencia

Este proyecto está bajo la licencia **MIT**.

```
MIT License

Copyright (c) 2025 Guillermo Diotti - Universidad ORT Uruguay

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<div align="center">

Made by Guillermo Diotti

</div>
