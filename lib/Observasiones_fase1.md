# Prompt complementario: observaciones de la Fase 1

Lee primero `lib/PROMPT_NEXORA.md` y luego este archivo. Este documento complementa el prompt principal con hallazgos de una revisión del estado actual del proyecto.

## Alcance

- Trabaja solo en las correcciones pendientes de la Fase 1. No implementes las notificaciones reales de la Fase 2, la importación de archivos de la Fase 3 ni las herramientas de estudio de la Fase 4.
- Inspecciona el estado actual de Git y conserva todos los cambios locales existentes. No uses reset, checkout destructivo ni reviertas trabajo del usuario.
- Nexora sigue siendo local y sin conexión. No añadas servidores, cuentas, APIs, sincronización, exportación, importación ni funciones de copia de seguridad.
- Antes de editar, resume brevemente el plan. Después realiza y valida las correcciones de este documento.

## Observaciones que hay que resolver

### 1. No perder silenciosamente datos con JSON dañado

En `lib/state/app_state.dart`, cuando el JSON completo de eventos o recursos no se puede decodificar, la app continúa con una lista vacía. Un guardado posterior puede sobrescribir el contenido dañado sin avisar.

- Distingue entre un contenedor JSON inválido y registros individuales inválidos.
- Si el contenedor completo está dañado, conserva intacta la cadena original existente y evita sobrescribir esa colección automáticamente. Muestra un mensaje claro y permite seguir usando las otras partes de la app.
- Si solo algunos registros están dañados, conserva los válidos y comunica cuántos se omitieron; no descartes toda la lista.
- No conviertas una fecha obligatoria inválida en `DateTime.now()`, porque puede crear un evento o recurso con una fecha inventada. Rechaza ese registro con un error controlado o usa una alternativa explícita que no aparente ser un dato real.
- Los campos opcionales sí pueden recibir valores predeterminados razonables.
- No agregues una copia de seguridad para resolver esto.

### 2. Permitir editar eventos antiguos

En `lib/widgets/add_event_dialog.dart`, el selector de fecha limita la selección a los últimos 30 días y al próximo año, pero el formulario de edición carga la fecha original del evento. Si esa fecha queda fuera del rango, el selector puede recibir un `initialDate` inválido.

- Ajusta los límites al modo de uso: al editar, el rango debe incluir la fecha guardada y permitir cambiarla sin provocar una aserción.
- Conserva validaciones razonables al crear eventos nuevos.
- Añade una prueba que abra la edición de un evento cuya fecha sea anterior a 30 días y permita guardar el cambio.

### 3. No presentar el interruptor de notificaciones como funcional antes de la Fase 2

En `lib/screens/settings_screen.dart`, el interruptor de Notificaciones solo cambia una preferencia; todavía no programa recordatorios.

- En esta fase, quítalo o muéstralo claramente deshabilitado con un texto que explique que los recordatorios se implementarán en la Fase 2.
- No añadas en este trabajo un plugin ni programación de notificaciones.
- No debe quedar un control que prometa recordatorios activos cuando no existen.

### 4. Revisar la configuración de copias de seguridad de Android

En `android/app/src/main/AndroidManifest.xml` se configuró `android:allowBackup="false"` y también `android:fullBackupContent="false"`.

- Mantén desactivada la copia automática de los datos de Nexora.
- Verifica la sintaxis con la documentación oficial de Android. `android:fullBackupContent` se usa para referenciar un XML de reglas; no lo dejes con el literal `false` si no corresponde. `android:allowBackup="false"` es la opción de exclusión que debes revisar para este caso.
- No afirmes que el comportamiento es idéntico en todos los fabricantes: documenta cualquier limitación de Android respecto a transferencias entre dispositivos.
- No implementes copias, restauración, exportación ni importación.

Referencia oficial: https://developer.android.com/guide/topics/manifest/application-element

### 5. Revisar el identificador Android de plantilla

En `android/app/build.gradle.kts` siguen apareciendo `com.example.name_none` como `namespace` y `applicationId`; también quedan identificadores de plantilla en el proyecto.

- Antes de distribuir una APK, determina un identificador estable y propio para Nexora.
- Revisa todos los usos del paquete en Gradle y Kotlin antes de cambiarlo. No hagas un reemplazo parcial.
- Antes de cambiarlo, informa que Android tratará el identificador nuevo como otra app y que los datos locales instalados bajo el identificador anterior no se migrarán automáticamente.
- Si no se puede decidir con seguridad en esta corrección, deja el punto señalado como pendiente previo a la distribución y no inventes que ya está resuelto.

### 6. Mejorar las pruebas para que comprueben el código real

`test/phase1_test.dart` contiene una prueba de límites de calendario que vuelve a implementar el cálculo de fechas dentro del propio test. Esa prueba puede pasar aunque la interfaz de Agenda tenga un error.

- Prueba la función real que usa el calendario o extrae el cálculo a una función reutilizable que use tanto la interfaz como la prueba.
- Cubre límites de mes y año, selección de día y filtrado de eventos desde el widget o desde la lógica real de Agenda.
- Añade cobertura para el onboarding: se muestra en el primer inicio, se guarda al completarlo y no vuelve a salir en un inicio posterior.
- Añade los casos de datos dañados y edición de eventos antiguos descritos arriba.
- Evita esperas fijas como `Future.delayed(Duration(milliseconds: 50))`; usa mecanismos de prueba deterministas.

### 7. No declarar la fase terminada sin validarla

El README marca la Fase 1 como completada, pero no hay resultados de validación confirmados en esta revisión.

- Ejecuta `flutter analyze`, `flutter test`, `flutter build apk --debug` y `flutter build web` si el entorno lo permite.
- Corrige los fallos relacionados con la Fase 1. Si un comando no puede ejecutarse, informa el error exacto y no declares esa validación como aprobada.
- Actualiza el estado de la Fase 1 en el README solo después de que los criterios aplicables se hayan verificado.
- No afirmes que se probó en un teléfono si solo se compiló la APK.

## Condiciones para cerrar esta corrección

- Los datos existentes no se sobrescriben silenciosamente cuando una colección almacenada no se puede leer.
- Se puede editar un evento antiguo sin que el selector de fecha falle.
- La configuración no presenta como activa una función de notificaciones aún no implementada.
- La configuración de Android para no realizar copias se revisó y usa sintaxis válida.
- Las pruebas verifican la lógica y flujos reales; las validaciones ejecutadas se reportan con sus resultados.
- No se iniciaron las fases 2, 3 ni 4.
