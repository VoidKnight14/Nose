# Prompt de arquitectura y desarrollo para Nexora

Actúa como mi compa de arquitectura y como desarrollador Flutter senior. Nexora es una app estudiantil para organizar fechas académicas y materiales. El proyecto Flutter ya existe y tiene versiones Android y web. Quiero que la app Android sea el producto principal y conservar web para revisar la interfaz.

## Principios obligatorios

- Nexora funciona localmente y sin conexión. No agregues backend, cuentas, inicio de sesión, sincronización, APIs, analítica, telemetría ni servicios remotos.
- Guarda eventos, preferencias y recursos en el dispositivo. Los archivos importados también deben quedarse en almacenamiento privado local.
- No implementes copias de seguridad, exportación ni importación. Al desinstalar la app se perderán los eventos, ajustes, recursos y archivos; la app no ofrecerá recuperación.
- Desactiva la copia automática de datos de Android para Nexora, de modo que los datos privados no se suban o restauren mediante la copia del sistema.
- Muestra claramente durante la bienvenida y en Configuración: “Nexora guarda tus datos solo en este dispositivo. Al desinstalar la app, se borrarán y no podrán recuperarse”. Android no permite que la app intercepte la desinstalación para mostrar un aviso propio.
- Mantén la interfaz en español y los archivos fuente en UTF-8. Prioriza Android, pero no rompas la compilación web ni la uses como prueba de funciones exclusivas de Android.
- No presentes una simulación como una función real. No reescribas la arquitectura ni elimines cambios locales del usuario sin necesidad técnica justificada.
- La bienvenida/onboarding se muestra solo en el primer inicio. Al completarla, guarda esa decisión localmente y abre Inicio directamente en los siguientes arranques. Solo debe volver a aparecer si los datos de la app se borran o se reinstala.

## Cómo trabajar: una fase por ejecución

1. Inspecciona primero los archivos, configuración, pruebas y cambios locales de Git. Informa brevemente lo que encontraste y el alcance de la fase solicitada.
2. Si no indico una fase, trabaja solo en la **Fase 1**. Implementa una sola fase por ejecución; no empieces las fases futuras ni agregues funciones fuera de alcance.
3. Antes de editar, presenta un plan breve. Luego realiza la fase completa, revisa los cambios y corrige los problemas relacionados con ella.
4. Conserva las decisiones y datos existentes cuando sea posible. Si una modificación requiere migrar datos, hazlo de forma compatible y explica el cambio.
5. Si un bloqueo real impide continuar, explica cuál es y avanza en las tareas independientes.

## Fases del producto

### Fase 1 — Estabilizar la app actual

- Corregir errores en Inicio, Agenda, Biblioteca, configuración, formularios y persistencia.
- El próximo evento debe ser estrictamente futuro y estar pendiente; nunca mostrar un evento vencido como próximo.
- Corregir el calendario para los límites entre meses y años. Los días deben corresponder a fechas reales y se debe poder seleccionar un día y consultar sus eventos.
- Completar el ciclo de eventos: crear, ver, editar, completar/reabrir y eliminar con confirmación.
- Corregir estados visuales que no se actualizan, como el favorito en el detalle de un recurso.
- Revisar el manejo de datos guardados dañados o incompletos y evitar que guardados concurrentes sobrescriban cambios recientes.
- No añadir todavía notificaciones programadas ni importación de archivos. Quita o desactiva las vistas simuladas de documentos para no fingir que se abre un archivo real.
- Actualizar el nombre visible, los textos de plantilla, la configuración Android y el README para identificar correctamente a Nexora. No cambies el identificador Android sin revisar sus referencias.
- Conservar y verificar que la bienvenida aparezca una sola vez; los inicios posteriores deben ir directamente a la app.
- Añadir el aviso de pérdida de datos en bienvenida y Configuración y desactivar la copia automática de datos de Android.

**Criterio de finalización:** la app actual es coherente, sus flujos existentes funcionan, los datos se conservan localmente y Android/web siguen compilando.

### Fase 2 — Recordatorios locales de Android

- Implementar notificaciones locales para los eventos; no usar servidor, internet ni push notifications.
- Permitir elegir un recordatorio útil (por ejemplo, a la hora del evento, 10 minutos, 1 hora o 1 día antes) y desactivarlo por evento.
- Pedir permiso de notificaciones de forma contextual y explicar qué hacer si se deniega.
- Programar, actualizar y cancelar avisos al crear, editar, completar o eliminar eventos, respetando la preferencia global de Configuración.
- Manejar zona horaria y reprogramación después de reiniciar Android, según lo requiera la versión compatible del plugin.
- Usa alarmas inexactas cuando sean suficientes. Solicita acceso a alarmas exactas solo si el comportamiento elegido realmente necesita puntualidad precisa, y maneja el caso en que Android deniegue ese acceso.
- Al tocar una notificación, abrir Nexora en el evento correspondiente cuando sea viable.
- Asegura que ejecutar Nexora en web no intente invocar APIs Android ni falle. La web sirve para revisar la interfaz; prueba los recordatorios en un emulador o teléfono Android.

**Criterio de finalización:** crear un evento en Android produce el aviso configurado; editarlo o borrarlo actualiza/cancela el aviso; permisos denegados y preferencia desactivada se manejan claramente.

### Fase 3 — Biblioteca con archivos reales

- Importar archivos mediante el selector de documentos de Android y copiarlos al almacenamiento privado de Nexora para no depender de una URI temporal.
- Guardar metadatos reales: título, materia/categoría, tipo, tamaño calculado, fecha y descripción opcional.
- Permitir buscar, filtrar, marcar favoritos, consultar detalles y eliminar con confirmación. Al eliminar el recurso, eliminar también su copia local.
- Implementar visualización real de PDF dentro de la app solo si se puede hacer de manera estable. Para otros formatos, usar el selector de aplicaciones Android para abrirlos o indicar claramente que no hay una app compatible.
- No generar vistas previas falsas ni aceptar tamaños de archivo inventados por el usuario.
- Mantener web compilable; si no tiene una función equivalente, mostrar un mensaje honesto en web en vez de romper esa plataforma.

**Criterio de finalización:** Nexora importa, conserva, muestra y elimina archivos reales en Android y nunca afirma haber abierto un archivo cuando no lo hizo.

### Fase 4 — Herramientas de estudio (después de las fases anteriores)

- Añadir una lista de tareas/checklist dentro de cada evento para dividir, por ejemplo, un examen en pasos de estudio.
- Considerar materias personalizables por el estudiante y relacionar recursos con materias y eventos.
- Considerar un horario semanal de clases recurrentes, con edición y fechas de inicio/fin del período lectivo.
- Implementar solo las funciones que encajen bien con el uso actual; presenta primero un plan corto y no conviertas Nexora en una app social o una plataforma escolar.

## Calidad común a todas las fases

- Mantén una interfaz clara y consistente con la identidad visual de Nexora, estados vacíos útiles, errores comprensibles y formularios desplazables en pantallas pequeñas.
- Revisa contraste, áreas táctiles, tamaño de texto, teclado y etiquetas accesibles.
- Usa dependencias compatibles con la versión de Flutter/Dart del proyecto y explica cada dependencia nueva.
- No cambies a una base de datos o arquitectura distinta salvo que justifiques el beneficio y la migración necesaria.
- Asegura que la app no realice solicitudes de red. El selector de Android puede presentar proveedores externos; Nexora no debe subir archivos por su cuenta.

## Validación y entrega por fase

1. Ejecuta `flutter analyze` y corrige los errores y advertencias causados por la fase.
2. Ejecuta las pruebas automatizadas existentes y añade pruebas enfocadas en los flujos modificados, sin ampliar el alcance.
3. Si el entorno lo permite, compila una APK de depuración para instalarla y probarla en Android. No afirmes que fue probada en un teléfono si no se ejecutó allí.
4. Revisa el diff y confirma que no se hayan perdido cambios locales previos.
5. Resume qué cambió, qué comandos se ejecutaron y sus resultados, qué limitaciones quedan y cuál fase sigue. Detente al terminar la fase solicitada.

## Distribución

La app se distribuirá como APK de forma individual, no mediante Google Play. No añadas requisitos de Play Store. Mantén un identificador Android estable y explica cómo generar una APK de depuración para pruebas. Si luego se prepara una APK release firmada, no guardes claves ni contraseñas de firma dentro del repositorio.
