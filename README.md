
Frontend Flutter de Pillmo para consultar la medicacion diaria, confirmar
dosis, escanear recetas y consultar la agenda y supervisión familiar.

## Arquitectura actual

La aplicación mantiene pocas capas y solo conserva abstracciones donde hay
logica de negocio o persistencia real:

```text
lib/
├── app/                         # router, tema y composición de la app
├── core/
│   ├── di/                      # registro manual de dependencias
│   ├── network/                 # Dio, API client e interceptores
│   ├── storage/                 # usuario local en almacenamiento seguro
│   └── widgets/                 # controles compartidos
└── features/
		├── auth/                    # sincronización y sesión local
		├── medications/             # timeline, confirmación y OCR
		├── appointments/            # estado de pacientes/cuidadores
		├── health_metrics/          # adherencia e historial
		├── home/                    # shell y navegación principal
		└── profile/                 # datos básicos de la sesión
```

Las capas `data/domain/presentation` completas se mantienen en autenticación
y medicamentos, donde existen varios casos de uso y estados asíncronos. Las
páginas de analítica y familia usan un adaptador HTTP pequeño porque sus
operaciones actuales son consultas de lectura.

## Servicios consumidos

| Módulo | Endpoint | Uso en la app |
| --- | --- | --- |
| Auth | `POST /api/v1/auth/sync` | Sincroniza el usuario y guarda su UUID local. |
| Timeline | `GET /api/v1/timeline/today` | Muestra las dosis del día. |
| Dosis | `PATCH /api/v1/doses/{id}/confirm` | Confirma una dosis tomada. |
| OCR | `POST /api/v1/prescriptions/scan` | Envía una foto JPEG/PNG desde cámara o galería. |
| Historial | `GET /api/v1/history` | Consulta las dosis de los últimos 30 días. |
| Analítica | `GET /api/v1/analytics/adherence` | Muestra el porcentaje de adherencia. |
| Familia | `GET /api/v1/family/status` | Muestra adherencia y pendientes de pacientes vinculados. |

El backend es la fuente de verdad. Una respuesta vacía de timeline (`[]`) es
un estado válido y muestra el estado inicial para incluir una receta.

## Flujos principales

1. El usuario sincroniza su identidad desde el formulario de acceso.
2. Inicio consulta la timeline diaria.
3. El FAB `+` abre el flujo de incluir receta con foto o el formulario manual.
4. El módulo OCR analiza la imagen y permite revisar los datos detectados.
5. El usuario confirma las dosis desde la timeline.
6. Agenda muestra las dosis de hoy ordenadas por hora y permite confirmarlas.
7. Familia consulta el estado diario de pacientes vinculados.

## Limitaciones actuales

- El backend no expone todavía un endpoint para crear medicamentos y horarios.
	El formulario manual es una interfaz provisional y no debe considerarse
	persistencia real.
- No existe un endpoint de citas; la pestaña correspondiente muestra el
	estado familiar de cuidadores.
- No existe todavía un endpoint de calendario mensual. La pestaña Agenda usa
	`GET /api/v1/timeline/today`, que es la fuente actual de horarios, dosis y
	estados del día.
- El login actual sincroniza un usuario de QA. La autenticación Firebase real
	y el envío del token FCM requieren integración adicional.

## Ejecución local

Inicia primero el backend en `http://127.0.0.1:8080` y después ejecuta:

```bash
flutter clean
flutter pub get
flutter run -d web-server \
	--web-port 3000 \
	--web-hostname 0.0.0.0 \
	--dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1
```

Si el puerto `3000` está ocupado, usa otro puerto y reinicia el backend para
que su política CORS permita ese origen local.

## Verificación

```bash
flutter test
dart analyze
flutter build web
```

Los modelos de timeline y OCR tienen pruebas de contrato con las respuestas
documentadas del backend.
# Pillmo-App

Scaffold inicial de Pillmo con Clean Architecture organizada por features.

## Estructura

Cada feature sigue el flujo `presentation -> domain -> data`:

```text
lib/
├── app/                 # Configuracion global, router y tema
├── core/                # Error, red, storage, DI, utils y widgets
├── features/
│   ├── auth/
│   ├── medications/
│   ├── appointments/
│   ├── health_metrics/
│   └── profile/
└── main.dart
```

Las features incluyen `data/datasources`, `data/models`,
`data/repositories`, `domain/entities`, `domain/repositories`,
`domain/usecases`, `presentation/blocs`, `presentation/pages` y
`presentation/widgets`.

## Documentación adicional

- [Resumen de backend y arquitectura](BACKEND_SUMMARY.md)

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Para desarrollo continuo: `make watch`. También están disponibles `make
format`, `make analyze` y `make test`.

La URL de API se puede cambiar al ejecutar con:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```
