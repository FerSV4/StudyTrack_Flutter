# StudyTrack

## Descripción del proyecto

StudyTrack es una plataforma digital híbrida (**Mobile y Web**) diseñada para unificar la organización del semestre académico, el seguimiento de entregas y tareas, y la medición de sesiones de estudio mediante la técnica **Pomodoro**.

El proyecto resuelve la fragmentación de herramientas universitarias integrando la agenda de actividades con mecanismos de enfoque en un solo flujo de trabajo altamente eficiente, seguro y resiliente.

## Características principales

### Onboarding y estructura académica

- Creación de semestres/ciclos lectivos con fechas de inicio y fin.
- Gestión de materias con códigos de color personalizados.

### Gestión inteligente de tareas (Agenda)

- CRUD completo de tareas asociadas a materias.
- Filtros por materia y estado de entrega.
- Cálculo y visualización de progreso académico en tiempo real.

### Temporizador Pomodoro nativo

- Vinculación automática con las tareas más urgentes del usuario.
- Duraciones personalizables de sesión (15, 25, 50 minutos).
- Interfaz de enfoque activo basada en renderizado personalizado (`CustomPainter`).

### Seguridad y autenticación

- Autenticación mediante **JSON Web Tokens (JWT)**.
- Integración biométrica nativa (**Face ID / Huella Dactilar**) mediante `local_auth`.

### Resiliencia y modo offline

- Sistema de degradación elegante con soporte offline.
- Detección automática del estado de red con banner de alerta reactivo.
- Persistencia en almacenamiento local para sesiones y caché.

## Arquitectura y tecnologías

La aplicación móvil/web está construida siguiendo los principios de **Clean Architecture** para garantizar escalabilidad, mantenibilidad y desacoplamiento.

### Frontend

La aplicación frontend está desarrollada con **Flutter** mediante un único código base para Android, iOS y Web.

| Componente | Tecnología |
|---|---|
| Lenguaje | Dart |
| Framework | Flutter SDK |
| Gestión de estado | BLoC / Cubit (`flutter_bloc`) |
| Inyección de dependencias | GetIt (Service Locator) |
| Cliente HTTP | Dio |
| Almacenamiento local | SharedPreferences |

#### Hardware e integraciones nativas

- `local_auth` — Biometría.
- `connectivity_plus` — Monitorización de red.
- `app_links` — Manejo de Deep Links.
- `image_picker` — Cámara y galería.

### Backend e infraestructura

- **API REST:** NestJS
- **Base de datos relacional:** PostgreSQL
- **ORM:** Prisma
- **Contenerización e infraestructura:** Docker, Kubernetes, CI/CD

## Estructura del proyecto

```text
lib/
├── core/
│   ├── di/              # Configuración del localizador de servicios (GetIt)
│   ├── network/         # Cliente Dio, interceptores y monitoreo de red
│   ├── theme/           # Paletas de color, tipografía y estilos globales
│   ├── design_system/   # Componentes y widgets reutilizables de UI
│   └── utils/           # Utilidades de formato, fechas y validadores
│
└── features/            # Módulos organizados por característica de negocio
    ├── auth/            # Autenticación, Login y Biometría
    ├── academic/        # Gestión de Semestres y Materias
    ├── tasks/           # CRUD de Tareas y Agenda
    ├── timer/           # Temporizador Pomodoro y Estado de Enfoque
    └── profile/         # Perfil de usuario y ajustes
        ├── data/        # Datasources (Remote/Local), Models y Repositorios Impl
        ├── domain/      # Entidades de negocio, Casos de Uso e Interfaces
        └── presentation/ # BLoCs, Páginas y Widgets del módulo
```

## Requisitos previos

- **Flutter SDK:** Versión 3.x o superior.
- **Dart SDK:** Versión 3.x o superior.
- **Android Studio / VS Code:** Con extensiones de Flutter y Dart.
- **Dispositivo físico o emulador:** Android API 21+ / iOS 12+.

## Instalación y configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/usuario/studytrack.git
```

### 2. Navegar al directorio del proyecto

```bash
cd studytrack
```

### 3. Instalar las dependencias de Flutter

```bash
flutter pub get
```

### 4. Configurar las variables de entorno

Crear un archivo `.env` en la raíz del proyecto con la siguiente estructura:

```env
API_BASE_URL=https://api.studytrack.com/v1
```

### 5. Ejecutar la verificación del entorno

```bash
flutter doctor
```

### 6. Iniciar la aplicación en modo desarrollo

```bash
flutter run
```

## Buenas prácticas implementadas

- Separación estricta de responsabilidades (**Presentación, Dominio y Datos**).
- Manejo reactivo de estados sin mutación directa.
- Caché de datos locales para continuidad operativa sin conexión a internet.
- Manejo global de excepciones e interceptores de red unificados.
