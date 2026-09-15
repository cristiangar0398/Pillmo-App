# Pillmo: servicios de negocio

Este documento explica qué problema de negocio resuelve cada servicio del backend de Pillmo, quién lo utiliza y qué resultado produce. Está pensado para producto, negocio y operaciones; los detalles de arquitectura, persistencia y configuración están en [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md) y en el [README.md](README.md).

## Vista general

| Servicio | Propósito de negocio | Estado | Entrada principal |
| --- | --- | --- | --- |
| [UserService](internal/core/services/user_service.go) | Mantener la identidad y el canal de notificaciones del usuario | Operativo | Datos de usuario y token del dispositivo |
| [ScheduleService](internal/core/services/schedule_service.go) | Mostrar las dosis del día y registrar una dosis tomada | Operativo | Usuario, agenda y confirmación de dosis |
| [AnalyticsService](internal/core/services/analytics_service.go) | Consultar el historial y medir la adherencia | Operativo | Usuario y periodo de consulta |
| [FamilyService](internal/core/services/family_service.go) | Permitir al cuidador supervisar a sus pacientes | Operativo | Identidad del cuidador |
| [OCRService](internal/core/services/ocr_service.go) | Convertir una receta fotografiada en información legible | Operativo cuando Gemini está configurado | Imagen JPEG o PNG |
| [NotificationWorker](internal/workers/notification_worker.go) | Avisar de dosis que llevan demasiado tiempo pendientes | Operativo cuando hay base de datos y FCM | Dosis vencidas |
| [AuthService](internal/core/services/services.go) | Registrar un usuario y emitir su token de acceso | Preparado, no conectado al router actual | Datos de usuario |
| [MedicationService](internal/core/services/services.go) | Confirmar una dosis desde el caso de uso de medicación | Preparado, no conectado al router actual | Agenda, usuario y hora de toma |

## 1. Usuarios y acceso a notificaciones

**Servicio:** [UserService](internal/core/services/user_service.go)

### Objetivo

Crear o actualizar el perfil de una persona que ya se ha autenticado con Firebase y guardar el dispositivo donde recibirá avisos de Pillmo.

### Qué permite

- Sincronizar el identificador de Firebase, email, nombre y rol.
- Mantener los roles de **paciente** (`PATIENT`) y **cuidador** (`CAREGIVER`).
- Actualizar el token FCM del dispositivo.
- Evitar perfiles incompletos y tokens vacíos.

### Flujo de negocio

1. La aplicación envía los datos básicos del usuario.
2. Pillmo valida y normaliza los datos.
3. Si el usuario ya existe en Firebase, actualiza su perfil; si no, lo crea.
4. El usuario puede registrar o renovar el token de su dispositivo.

### Canales actuales

- `POST /api/v1/auth/sync`
- `PATCH /api/v1/users/fcm-token`

## 2. Agenda diaria y confirmación de dosis

**Servicio:** [ScheduleService](internal/core/services/schedule_service.go)

### Objetivo

Convertir la agenda de medicación en una lista diaria que el paciente pueda consultar y actualizar con una acción rápida.

### Qué permite

- Consultar todas las dosis previstas para el día actual.
- Ordenar las dosis por hora programada.
- Mostrar el medicamento, dosis, icono, color y estado.
- Marcar una dosis como tomada usando la hora actual o una hora indicada por el paciente.

### Estados de una dosis

- **Pendiente:** todavía no se ha registrado una acción.
- **Tomada:** el paciente confirmó la toma.
- **Omitida:** la dosis fue omitida según el registro del tratamiento.
- **Atrasada:** el sistema detectó que seguía pendiente después del margen establecido.

### Canales actuales

- `GET /api/v1/timeline/today`
- `PATCH /api/v1/doses/{id}/confirm`

La consulta de la agenda usa el día actual en UTC. La hora mostrada al usuario se presenta con formato `HH:mm`.

## 3. Historial y adherencia

**Servicio:** [AnalyticsService](internal/core/services/analytics_service.go)

### Objetivo

Dar al paciente una visión de su comportamiento de medicación: qué ocurrió en un periodo concreto y qué porcentaje de dosis está cumpliendo.

### Qué permite

- Consultar el historial de dosis entre dos fechas.
- Calcular la adherencia total de los últimos 30 días.
- Desglosar la adherencia por medicamento.
- Contabilizar dosis tomadas, omitidas, pendientes y totales.

### Regla de negocio

La adherencia se calcula como:

`dosis tomadas / dosis totales * 100`

El resultado se redondea a dos decimales. Cuando no existen dosis en el periodo, la adherencia es `0%`. En la API, la fecha final solicitada por el cliente es inclusiva.

### Canales actuales

- `GET /api/v1/history?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD`
- `GET /api/v1/analytics/adherence`

## 4. Supervisión familiar

**Servicio:** [FamilyService](internal/core/services/family_service.go)

### Objetivo

Permitir que un cuidador conozca rápidamente el estado de adherencia de los pacientes vinculados a su red familiar.

### Qué permite

- Consultar los pacientes asociados a un cuidador.
- Ver el porcentaje de dosis tomadas durante el día.
- Identificar cuántas dosis siguen pendientes o atrasadas por paciente.

### Resultado para el cuidador

Cada paciente se devuelve con su identidad, porcentaje diario de adherencia y número de dosis pendientes. Si el paciente no tiene dosis registradas ese día, su porcentaje es `0%`.

### Canal actual

- `GET /api/v1/family/status`

## 5. Escaneo de recetas

**Servicio:** [OCRService](internal/core/services/ocr_service.go)

### Objetivo

Reducir la carga de introducir manualmente un tratamiento: el usuario fotografía una receta y Pillmo devuelve los datos que puede reconocer.

### Qué permite

- Recibir una receta en formato JPEG o PNG.
- Extraer nombre del medicamento, dosis, frecuencia, duración e instrucciones.
- Devolver la información estructurada para que la aplicación la revise o la use en el siguiente paso del alta del tratamiento.

### Límites actuales

- No guarda automáticamente los medicamentos detectados.
- Rechaza imágenes vacías y formatos distintos de JPEG o PNG.
- La capacidad está disponible solo cuando se configura la integración con Gemini.

### Canal actual

- `POST /api/v1/prescriptions/scan`

## 6. Avisos de dosis atrasadas

**Componente de negocio:** [NotificationWorker](internal/workers/notification_worker.go)

### Objetivo

Evitar que una dosis pendiente pase desapercibida y mantener informados al paciente y a sus cuidadores.

### Flujo de negocio

1. El sistema revisa periódicamente las dosis pendientes.
2. Detecta las que superan 15 minutos desde su hora programada.
3. Envía un aviso push al paciente.
4. Envía el aviso a los cuidadores vinculados cuando corresponde.
5. Marca la dosis como atrasada para no repetir el mismo procesamiento.

El worker se ejecuta cada cinco minutos cuando la aplicación tiene configurada la base de datos. El envío real requiere FCM; sin credenciales, el adaptador puede funcionar en modo de registro local.

## 7. Capacidades preparadas para una siguiente fase

### Registro y emisión de acceso

**Servicio:** [AuthService](internal/core/services/services.go)

Este servicio representa el flujo de alta de un usuario desde el punto de vista de negocio: valida los datos básicos, crea el usuario y solicita un token de acceso. Está preparado como caso de uso, pero actualmente no está conectado al router HTTP porque todavía requiere un emisor de tokens (`TokenIssuer`).

### Confirmación desde el módulo de medicación

**Servicio:** [MedicationService](internal/core/services/services.go)

Este servicio encapsula la acción de confirmar una dosis asociada a un horario y un paciente. Está preparado para una futura ruta del módulo de medicación, pero el flujo activo de la API utiliza actualmente `ScheduleService` y `PATCH /api/v1/doses/{id}/confirm`.

## Relación con la aplicación

Estos servicios cubren el ciclo principal de Pillmo:

1. El usuario se identifica y registra su dispositivo.
2. Consulta su agenda diaria.
3. Confirma las dosis que toma.
4. Recibe avisos si una dosis queda atrasada.
5. Revisa su historial y adherencia.
6. Comparte visibilidad con sus cuidadores.
7. Puede acelerar la carga de un tratamiento mediante el escaneo de una receta.

Para el detalle de rutas, contratos HTTP, reglas técnicas y estado de implementación, consulta [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md).