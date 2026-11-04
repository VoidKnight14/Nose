# Nexora

Nexora es una aplicación móvil estudiantil para organizar fechas académicas y materiales de estudio de forma 100% local y privada.

## Principios de la Aplicación

- **Funcionamiento 100% local y sin conexión:** Nexora no utiliza servidores, cuentas, bases de datos remotas ni analítica. Todos los datos permanecen exclusivamente en el dispositivo del estudiante.
- **Privacidad total:**
  > *Nexora guarda tus datos solo en este dispositivo. Al desinstalar la app, se borrarán y no podrán recuperarse.*
- **Sin copia automática en la nube:** La copia de seguridad del sistema Android está desactivada (`android:allowBackup="false"`). En Android 12+ algunos fabricantes pueden permitir la transferencia directa entre dispositivos; Nexora no implementa copia, exportación ni restauración.
- **Distribución directa:** Nexora se distribuye directamente mediante APK independiente.

---

## Funcionalidades Actuales (Fases 1, 2, 3 y 4)

1. **Pantalla de Inicio (Panel General):**
   - Resumen del próximo evento estrictamente pendiente y a futuro (nunca eventos vencidos).
   - Acceso rápido a la Biblioteca Digital y métricas locales.
2. **Agenda Académica:**
   - Calendario con cálculo de fechas reales (manejo de límites de mes y año sin desbordes).
   - Navegación entre meses y semanas.
   - Selección interactiva de día para filtrar eventos programados e indicador de puntos en días con actividad.
   - Ciclo completo de eventos: crear, visualizar detalles, editar, marcar completado/reabrir y eliminar con diálogo de confirmación.
   - Recordatorio por evento: sin recordatorio, a la hora, 10 minutos, 1 hora o 1 día antes.
3. **Recordatorios locales (Fase 2, solo Android):**
   - Notificaciones programadas en el propio dispositivo, sin servidores ni notificaciones push.
   - Se programan al crear o editar un evento y se cancelan al eliminarlo o marcarlo como completado.
   - Se reprograman al abrir la app, al activar la preferencia global y tras reiniciar el dispositivo.
   - En el primer inicio, la app solicita una sola vez el permiso de notificaciones de Android; si se concede, activa los recordatorios.
   - Al guardar un recordatorio, solicita el acceso especial a alarmas exactas de Android cuando aún no está concedido.
   - Al tocar la notificación, Nexora abre el detalle del evento (también en arranque en frío).
   - En web la compilación sigue funcionando; no se invoca ninguna API de Android.
4. **Biblioteca Digital con archivos reales (Fase 3, solo Android para importar):**
   - Importación mediante el selector de documentos de Android.
   - El archivo se copia al almacenamiento privado de Nexora; no se depende del archivo original ni de una URI temporal.
   - Título, materia, tipo y tamaño se obtienen del archivo real; el tamaño ya no se escribe a mano.
   - Búsqueda, filtro por materia, favoritos, detalle y eliminación con confirmación.
   - Al eliminar un recurso se borra también su copia local.
   - Visor de PDF dentro de la app (PDFium mediante `pdfrx`).
   - Otros formatos (DOCX, TXT, ZIP, etc.) se abren con la aplicación que el usuario elija en Android; si no hay ninguna compatible, se muestra un mensaje claro.
   - En web se puede revisar la interfaz y los recursos existentes, pero la importación muestra un aviso de que solo está disponible en Android.
   - Los recursos creados antes de la Fase 3 no tienen archivo asociado y se avisa de ello en su detalle.
5. **Herramientas de estudio (Fase 4):**
   - Checklist dentro de cada evento: añadir pasos, marcarlos como hechos y eliminarlos; se guarda con el evento.
   - Materias personalizables: se crean al escribir una materia nueva en un evento o recurso, o desde Ajustes.
   - Los filtros de la Biblioteca usan las materias reales del usuario, no una lista fija.
   - La app arranca completamente vacía: no hay eventos, recursos ni materias de ejemplo.
   - El horario semanal de clases quedó fuera de esta fase; requeriría un modelo de recurrencia y edición de períodos lectivos que no encaja con el alcance actual.
6. **Configuración y Bienvenida:**
   - Modo oscuro y modo claro.
   - Interruptor general de notificaciones, desactivado por defecto; al activarlo se solicita el permiso del sistema.
   - Aviso explícito de almacenamiento local y pérdida de datos al desinstalar.
   - Onboarding persistente: se muestra únicamente en el primer inicio tras la instalación.

---

## Estructura del Proyecto

```text
lib/
├── main.dart                      # Entrada de la app, MaterialApp y control de primer inicio
├── models/
│   ├── agenda_event.dart          # Modelo de evento con parsing defensivo y serialización
│   ├── event_task.dart            # Paso del checklist de un evento
│   └── library_resource.dart      # Modelo de recurso con parsing tolerante a fallos
├── screens/
│   ├── agenda_tab.dart            # Pestaña de Agenda y Calendario
│   ├── home_tab.dart              # Pestaña de Inicio
│   ├── library_tab.dart           # Pestaña de Biblioteca
│   ├── main_layout.dart           # Estructura principal con IndexedStack y navegación
│   ├── onboarding_screen.dart     # Pantalla de bienvenida (primer inicio)
│   ├── pdf_viewer_screen.dart     # Visor de PDF dentro de la app
│   └── settings_screen.dart       # Pantalla de configuración y aviso de privacidad
├── services/
│   ├── library_storage.dart       # Selección de la implementación de almacenamiento
│   ├── library_storage_io.dart    # Importación, apertura y borrado real de archivos
│   ├── library_storage_web.dart   # Avisos honestos en web
│   ├── library_storage_types.dart # Tamaño formateado y datos del archivo elegido
│   └── notification_service.dart  # Recordatorios locales de Android (permiso, programación y taps)
├── state/
│   └── app_state.dart             # Estado global con ChangeNotifier y persistencia serializada
├── utils/
│   └── calendar_utils.dart        # Cálculo de semanas, meses y comparación de días
└── widgets/
    ├── add_event_dialog.dart      # Diálogo para crear y editar eventos
    ├── add_resource_dialog.dart   # Importación de archivos y metadatos reales
    ├── event_detail_modal.dart    # Detalle, edición, toggle y eliminación de eventos
    └── resource_detail_modal.dart # Detalle, toggle favorito y eliminación de recursos
```

---

## Compilación y Ejecución

### Requisitos previos
- Flutter SDK (>= 3.12.2)
- Android SDK instalado y configurado

### Ejecución en modo desarrollo
```bash
flutter run
```

### Generación de APK de depuración para pruebas
Para generar una APK de depuración e instalarla directamente en un dispositivo o emulador Android:
```bash
flutter build apk --debug
```
El ejecutable generado con el nombre de la app se ubica en:
```text
build/app/outputs/flutter-apk/Nexora.apk
```
Además, cada compilación copia automáticamente el instalador listo para pasar al teléfono a:
```text
Compilado/Nexora.apk
Compilado/LEEME.txt
```
Flutter también deja la copia original `app-debug.apk` en la carpeta de salida, necesaria para sus herramientas internas. Ambas APK son idénticas.
Para instalar directamente en un dispositivo conectado:
```bash
adb install -r build/app/outputs/flutter-apk/Nexora.apk
```

### Probar en un Samsung A14 desde Windows (ADB)
1. Instala **Android SDK Platform-Tools** desde [la página oficial](https://developer.android.com/tools/releases/platform-tools) y extrae el ZIP, por ejemplo en `C:\platform-tools`. Alternativamente, instala Platform-Tools desde Android Studio > SDK Manager > SDK Tools.
2. Para USB, instala el [Samsung Android USB Driver](https://developer.samsung.com/android-usb-driver) y conecta el teléfono con un cable de datos. En el A14 activa **Opciones de desarrollador > Depuración por USB** y acepta el aviso de autorización. El controlador MTP por sí solo no siempre incluye la interfaz ADB.
3. Abre PowerShell en la carpeta `platform-tools` (o agrega esa carpeta al `Path`) y verifica la conexión:
   ```powershell
   .\adb.exe devices
   ```
   Debe aparecer el número de serie seguido de `device`. Si aparece `unauthorized`, desbloquea el teléfono y acepta el diálogo RSA.
4. Para instalar/actualizar la app por USB:
   ```powershell
   .\adb.exe install -r C:\ruta\al\proyecto\Compilado\Nexora.apk
   ```
5. Para Wi-Fi, conecta el PC y el teléfono a la misma red; en Android 11 o posterior abre **Opciones de desarrollador > Depuración inalámbrica > Emparejar dispositivo con código**. Ejecuta el comando con la dirección y el puerto de emparejamiento que muestra el teléfono, introduce el código temporal y luego conecta usando la dirección/puerto de conexión que muestra la pantalla principal de Depuración inalámbrica:
   ```powershell
   .\adb.exe pair <IP_DEL_TELEFONO>:<PUERTO_DE_EMPAREJAMIENTO>
   # Introduce el código temporal que muestra el teléfono.
   .\adb.exe connect <IP_DEL_TELEFONO>:<PUERTO_DE_CONEXION>
   .\adb.exe devices
   ```
   El código de emparejamiento es temporal. El puerto para `adb connect` puede cambiar; si `5555` no coincide con el que muestra el teléfono, usa el puerto actual de esa pantalla. Para volver a USB, desactiva Depuración inalámbrica o desconecta la sesión con `adb disconnect`.

### Ejecución en Web (revisión de interfaz)
```bash
flutter run -d chrome
```

---

## Notas Técnicas

> **Identificador Android:** El `applicationId` es `com.nexora.app` (namespace y `MainActivity` en `android/app/src/main/kotlin/com/nexora/app/`). iOS usa el mismo identificador base. **Atención:** si alguien tenía instalada una compilación con el `applicationId` anterior (`com.example.name_none`), Android la trata como una app distinta: no se actualiza encima y sus datos locales no se migran.

### Dependencias de la Fase 2
- `flutter_local_notifications` 22.3.3: programación y cancelación de notificaciones locales.
- `timezone` 0.11.2 y `flutter_timezone` 5.1.1: programación en la zona horaria real del dispositivo.
- El plugin requiere desugaring de librerías Java (`desugar_jdk_libs`), ya habilitado en `android/app/build.gradle.kts`.

### Dependencias de la Fase 3
- `file_picker` 13.3.2: selector de documentos de Android (Storage Access Framework).
- `path_provider` 2.1.6: carpeta privada de la app donde se copian los archivos.
- `pdfrx` 2.4.8: visor de PDF con PDFium; añade código nativo al APK.
- `open_filex` 5.0.0: abre formatos no PDF con la aplicación elegida por el usuario.

### Permisos y receptores Android
- `POST_NOTIFICATIONS`: se solicita una vez en el primer inicio; si se concede, se activan los recordatorios.
- `SCHEDULE_EXACT_ALARM`: acceso especial que el usuario concede desde los ajustes de Android; Nexora lo solicita al guardar un recordatorio.
- `VIBRATE`: vibración estándar de la notificación.
- `RECEIVE_BOOT_COMPLETED` y `ScheduledNotificationBootReceiver`: reprograman los recordatorios tras reiniciar el dispositivo o actualizar la app.
- Las variantes de depuración y perfil incluyen `INTERNET` para las herramientas de Flutter (por ejemplo, el servicio de depuración); Nexora no envía datos a servidores. La variante release no declara ese permiso.
- Se usan alarmas **exactas** (`exactAllowWhileIdle`) cuando Android concede el acceso especial. Si se deniega, se revoca o falla la programación exacta, Nexora conserva el evento y usa una alarma inexacta; en ese caso el aviso puede retrasarse. El modo ahorro de energía y las restricciones del fabricante también pueden afectar la entrega: no se puede garantizar puntualidad absoluta.
- La importación usa el selector del sistema, así que **no se piden permisos amplios de almacenamiento**. Las declaraciones de acceso a medios que traía `open_filex` se eliminan explícitamente en el manifiesto.

### Limitaciones conocidas
- Si el usuario desactiva las notificaciones del sistema después de concederlas, los avisos no se muestran; la app no vuelve a insistir automáticamente.
- Los recordatorios y la importación de archivos solo existen en Android. En web e iOS la app funciona, pero no programa avisos ni importa archivos.
- Si cambia la zona horaria del dispositivo, el horario se corrige la próxima vez que se abre la app; no hay un servicio en segundo plano escuchando ese cambio.
- El identificador interno de notificación es un hash de 31 bits del ID del evento; una colisión entre dos eventos es posible en teoría (documentado en el código).
- Nexora copia el archivo al importarlo: si el original cambia o se borra, la copia de Nexora no se actualiza.
- El archivo copiado se guarda en el almacenamiento privado de la app y se borra al desinstalarla o al eliminar el recurso. No hay nube ni restauración.
- Los recursos creados antes de la Fase 3 solo conservan metadatos; para abrirlos hay que eliminarlos y volver a importar el archivo real.
- El checklist y las materias son locales y se guardan con el resto de datos; no se sincronizan entre dispositivos.
- No hay horario semanal de clases recurrentes en esta versión. Los eventos son fechas puntuales.

---

## Estado de validación (Fases 1, 2, 3 y 4)

Verificado el 04/11/2026:

- `flutter analyze`: sin problemas.
- `flutter test`: 40 pruebas aprobadas (calendario, ciclo de eventos, datos dañados, onboarding, permiso inicial único, edición de eventos antiguos, filtrado por día, favoritos, recordatorios, archivos de la Biblioteca, checklist, materias personalizadas y layout móvil de Agenda).
- `flutter build web`: compilación correcta con los plugins de notificaciones y de archivos.
- `flutter build apk --debug`: compilación correcta; APK en `build/app/outputs/flutter-apk/app-debug.apk` y copia lista en `Compilado/Nexora.apk`, con `package: com.nexora.app` y etiqueta `Nexora`.
- El manifiesto declara `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `VIBRATE`, `RECEIVE_BOOT_COMPLETED` e `INTERNET` (este último solo en debug/profile); no se piden permisos de almacenamiento ni de medios.

La versión anterior se probó en un Samsung A14: la notificación inexacta llegó dos minutos después de la hora programada y al tocarla abrió el evento correcto. La nueva compilación todavía no se instaló en el dispositivo; quedan pendientes de prueba en el A14 el permiso inicial, el acceso a alarmas exactas y la entrega puntual con la nueva programación.

---

## Hoja de Ruta

- [x] **Fase 1:** Estabilización de la app actual, persistencia local segura, corrección del calendario, ciclo de eventos y avisos de privacidad.
- [x] **Fase 2:** Recordatorios locales de Android (sin servidores ni notificaciones push).
- [x] **Fase 3:** Biblioteca con archivos reales del dispositivo y almacenamiento privado.
- [x] **Fase 4:** Checklist por evento y materias personalizables. El horario semanal recurrente se evaluó y se dejó fuera por alcance.
