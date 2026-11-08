# REAL FLIGHT SIMULATOR MOBILE

Prototipo educativo en Godot 4.3, pensado para Android y para un dispositivo de entrada como OPPO A53 (4 GB RAM / Snapdragon 460). El proyecto usa el renderizador **Compatibility / OpenGL** y una interfaz 2D de resolución base 960 × 432.

## Incluido actualmente

- Escena 3D provisional con terreno, pista y avión placeholder generado por código.
- Cámara de cabina y cámara exterior intercambiables.
- Controles táctiles de potencia, batería, motores, tren, flaps y actitud.
- **PFD gráfico básico**: horizonte artificial esquemático, cintas IAS/ALT, actitud y velocidad vertical.
- **ND gráfico básico**: rosa de rumbo móvil y marca del rumbo seleccionado.
- **MCP básico**: selectores de velocidad, rumbo y altitud; botones H (HDG HOLD) y A (ALT HOLD).
- Piloto automático educativo simplificado que usa los valores seleccionados cuando está activado.

Los instrumentos gráficos se dibujan por código, sin texturas pesadas ni modelos 3D adicionales, para mantener bajo el consumo de memoria y GPU.

## Probar el proyecto

1. En GitHub, abre **Code → Download ZIP** y descomprime el proyecto.
2. Abre la carpeta del proyecto en Godot 4.3 o una versión 4.x compatible.
3. Importa el archivo `project.godot` y ejecuta la escena principal.
4. Enciende BATERÍA y MOTORES; mueve POTENCIA para cambiar la velocidad.
5. Usa los botones +/− del MCP para ajustar SPD, HDG y ALT. H y A activan/desactivan los modos de mantenimiento de rumbo y altitud.
6. Activa AP para que el prototipo intente seguir los valores seleccionados.

Para trabajar únicamente desde un teléfono Android, se necesita una versión de **Godot Editor para Android** compatible con el proyecto. La importación, ejecución y exportación pueden variar según la versión y la memoria disponible; todavía no se han probado en el OPPO A53. Si el editor muestra un error, conserva una captura del mensaje y del registro para corregirlo.

## Estado de Android

**No existe todavía un APK verificado.** La exportación necesita plantillas y configuración Android (SDK/JDK y firma); no se ha comprobado que todo ese proceso pueda completarse desde el OPPO A53.

## Limitaciones y seguridad

Este es un **prototipo educativo no certificado**, no apto para entrenamiento aeronáutico ni para tomar decisiones de vuelo reales. El avión, la física, PFD, ND y piloto automático son aproximaciones didácticas. No hay FMC/CDU, navegación real, mapas, radioayudas ni sistemas reales del Boeing 737-800 NG.
