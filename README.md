# Heroes of the Storm Replay Analysis

Este proyecto procesa archivos de repetición (.StormReplay) de Heroes of the Storm para extraer estadísticas detalladas de partidas y jugadores.

## Configuración Inicial

### 1. Crear Directorio de Archivos de Repetición
```bash
mkdir Saves
```
**IMPORTANTE**: Coloca tus archivos `.StormReplay` en el directorio `Saves/`. Este directorio no se incluye en el repositorio debido al gran tamaño de los archivos de repetición.

### 2. Instalar Dependencias
- .NET 8.0 Runtime
- heroes-decode 1.4.1
- heroesdataparser 4.14.0

## Archivos del Proyecto

### Scripts
- `heroesdecode.ps1` - Script principal de PowerShell para procesar archivos de repetición

### Datos (Generados al ejecutar)
- `Saves/` - Directorio con archivos .StormReplay (NO incluido en el repositorio)
- `structured_data.csv` - Datos extraídos en formato CSV estructurado
- `combined_output.csv` - Salida de texto legible combinada
- `json_output/` - Archivos JSON individuales por partida

## Uso

### Procesamiento Completo (todos los archivos)
```powershell
.\heroesdecode.ps1
```

### Procesamiento de Prueba (solo 10 archivos)
Editar la línea 34 en `heroesdecode.ps1` y cambiar:
```powershell
# De:
$replay_files = Get-ChildItem -Path $replay_dir -Filter "*.StormReplay"

# A:
$replay_files = Get-ChildItem -Path $replay_dir -Filter "*.StormReplay" | Select-Object -First 10
```

## Datos Extraídos

El script extrae la siguiente información de cada partida:

### Información de Partida
- Fecha y hora
- Mapa jugado
- Modo de juego
- Versión del juego
- Región del servidor
- Duración de la partida
- Equipo ganador

### Información de Jugadores
- Nombre del jugador
- Nivel de cuenta
- Héroe seleccionado
- Nivel del héroe
- Equipo (azul/rojo)
- Talentos por nivel (1, 4, 7, 10, 13, 16, 20)

### Estadísticas Detalladas
- Eliminaciones (kills)
- Asistencias (assists)
- Muertes (deaths)
- Daño a héroes
- Curación realizada
- Daño a estructuras
- Experiencia contribuida
- Tiempo muerto
- Premios obtenidos

## Requisitos del Sistema

- Windows con PowerShell
- .NET 8.0 Runtime
- heroes-decode 1.4.1
- heroesdataparser 4.14.0

## Estructura de Datos CSV

## Estructura de Archivos

```
heroes-storm-replay-analyzer/
├── README.md                    # Documentación del proyecto
├── .gitignore                   # Archivos excluidos del repositorio
├── heroesdecode.ps1            # Script principal funcional
├── Saves/                      # Directorio para archivos .StormReplay (crear manualmente)
├── structured_data.csv         # Datos CSV estructurados (generado)
├── combined_output.csv         # Salida de texto legible (generado)
└── json_output/                # Archivos JSON individuales (generado)
```

**Nota**: Los archivos marcados como "(generado)" se crean al ejecutar el script y no están incluidos en el repositorio.

## Notas

- El script procesa **TODOS los archivos** por defecto para análisis completo
- El script usa procesamiento secuencial para máxima compatibilidad
- Cada archivo .StormReplay genera datos para 10 jugadores (5 por equipo)
- Los archivos JSON individuales se guardan en `json_output/` para referencia
- El procesamiento completo de 426+ archivos toma aproximadamente 15-20 minutos
- Para modo de prueba (10 archivos), modifica el script según las instrucciones de uso

## Contribuir

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Contacto

Si tienes preguntas o sugerencias sobre el proyecto, no dudes en abrir un issue en GitHub.
