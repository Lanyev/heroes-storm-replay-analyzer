# Heroes of the Storm Replay Analysis

Este proyecto procesa archivos de repetición (.StormReplay) de Heroes of the Storm para extraer estadísticas detalladas de partidas y jugadores, utilizando tecnologías modernas de análisis de datos.

## 🔧 Tecnologías y Herramientas

### Decodificador Principal
- **[heroes-decode](https://github.com/nydus/heroes-decode)** v1.4.1 - Herramienta de línea de comandos para decodificar archivos .StormReplay
- **[heroesdataparser](https://github.com/nydus/heroesdataparser)** v4.14.0 - Parser de datos de Heroes of the Storm

### Stack Tecnológico
- **PowerShell** - Script principal de automatización y procesamiento
- **.NET 8.0 Runtime** - Entorno de ejecución requerido por heroes-decode
- **CSV/JSON** - Formatos de salida estructurados para análisis de datos
- **Git** - Control de versiones del proyecto

### Características del Decodificador
- Soporte completo para archivos .StormReplay de todas las versiones
- Extracción de metadatos de partida y estadísticas de jugadores
- Procesamiento de talentos y habilidades por nivel
- Análisis de eventos temporales de la partida
- Exportación a múltiples formatos (JSON, CSV, texto)

## 🌍 Normalización de Nombres de Héroes

El proyecto incluye un sistema robusto de normalización que convierte automáticamente los nombres de héroes del español al inglés:

### Mapeo Automático
- **Fuente**: `heroenames.txt` - Lista bilingüe oficial de nombres de héroes
- **Ejemplos de conversión**:
  - `Fénix` → `Fenix`
  - `Cringris` → `Greymane`
  - `El Carnicero` → `The Butcher`
  - `Azmodán` → `Azmodan`
  - `Puntos` → `Stitches`

### Beneficios
- **Consistencia**: Todos los nombres en inglés estándar
- **Compatibilidad**: Compatible con bases de datos internacionales
- **Análisis**: Facilita agregaciones y comparaciones de datos

## 📋 Configuración Inicial

### 1. Requisitos del Sistema
```powershell
# Verificar PowerShell (Windows)
$PSVersionTable.PSVersion

# Instalar .NET 8.0 Runtime si no está instalado
# Descargar desde: https://dotnet.microsoft.com/download/dotnet/8.0
```

### 2. Instalar Decodificador
```bash
# Instalar heroes-decode globalmente
npm install -g heroes-decode@1.4.1

# O descargar binario desde GitHub releases
# https://github.com/nydus/heroes-decode/releases
```

### 3. Crear Directorio de Archivos de Repetición
```bash
mkdir Saves
```
**IMPORTANTE**: Coloca tus archivos `.StormReplay` en el directorio `Saves/`. Este directorio no se incluye en el repositorio debido al gran tamaño de los archivos de repetición.

## 🚀 Uso del Proyecto

### Procesamiento Completo (Todos los Archivos)
```powershell
# Ejecutar script principal - procesa TODAS las partidas
.\heroesdecode.ps1
```

### Personalización del Procesamiento
Para modificar el número de archivos a procesar, edita la línea 159 en `heroesdecode.ps1`:

```powershell
# Procesar solo los primeros 50 archivos
$replay_files = Get-ChildItem -Path $replay_dir -Filter "*.StormReplay" | Sort-Object Name | Select-Object -First 50

# Procesar todos los archivos (configuración actual)
$replay_files = Get-ChildItem -Path $replay_dir -Filter "*.StormReplay" | Sort-Object Name
```

## 📊 Decodificación y Procesamiento

### Comando heroes-decode
El script utiliza internamente el siguiente comando para cada archivo:
```bash
heroes-decode --gameevents --messageevents --trackerevents --attributeevents --header --details --initdata --stats --json "archivo.StormReplay"
```

### Parámetros de Decodificación
- `--gameevents`: Eventos de juego (muertes, objetivos, etc.)
- `--messageevents`: Mensajes de chat y pings
- `--trackerevents`: Eventos de seguimiento de estadísticas
- `--attributeevents`: Atributos de jugadores y héroes
- `--header`: Información de cabecera del archivo
- `--details`: Detalles de la partida
- `--initdata`: Datos de inicialización
- `--stats`: Estadísticas finales de jugadores
- `--json`: Formato de salida JSON estructurado

## 📁 Archivos del Proyecto

### Scripts Principales
- `heroesdecode.ps1` - Script principal de PowerShell que orquesta el procesamiento
- `heroenames.txt` - Lista bilingüe oficial de nombres de héroes (español ↔ inglés)

### Datos de Entrada
- `Saves/` - Directorio con archivos .StormReplay (NO incluido en el repositorio)

### Datos de Salida (Generados automáticamente)
- `structured_data.csv` - **Dataset principal** en formato CSV estructurado
- `combined_output.csv` - Salida de texto legible para revisión manual
- `json_output/` - Archivos JSON individuales por partida para análisis detallado

## 📈 Datos Extraídos y Estructura

### Información de Partida
- **Timestamp**: Fecha y hora de la partida
- **Mapa**: Nombre del mapa jugado (ej: "Ciudad argenta", "Puesto de avanzada de Braxis")
- **Modo de juego**: Tipo de partida (ARAM, Ranked, Quick Match, etc.)
- **Versión**: Versión del cliente de Heroes of the Storm
- **Región**: Servidor donde se jugó la partida
- **Duración**: Tiempo total de la partida
- **Equipo ganador**: Resultado de la partida

### Información de Jugadores (10 por partida)
- **Datos de cuenta**: Nombre del jugador y nivel de cuenta
- **Héroe**: Héroe seleccionado (normalizado al inglés)
- **Nivel de héroe**: Experiencia específica con ese héroe
- **Equipo**: Blue (azul) o Red (rojo)
- **Builds completos**: Talentos seleccionados en niveles 1, 4, 7, 10, 13, 16, 20

### Estadísticas Detalladas de Combate
#### Estadísticas Básicas
- **Kills/Deaths/Assists**: Eliminaciones, muertes y asistencias
- **Takedowns**: Participaciones en eliminaciones
- **Hero Damage**: Daño infligido a héroes enemigos
- **Damage Taken**: Daño recibido
- **Healing**: Curación realizada a aliados
- **Self Healing**: Auto-curación

#### Estadísticas Avanzadas
- **Structure Damage**: Daño a edificios y estructuras
- **Siege Damage**: Daño de asedio total
- **Minion Damage**: Daño a esbirros
- **Experience**: Experiencia contribuida al equipo
- **Time Spent Dead**: Tiempo muerto total
- **Mercenary Camps**: Campamentos de mercenarios capturados
- **Watch Tower Captures**: Torres de vigilancia capturadas

#### Control de Masas (CC)
- **Rooting**: Tiempo inmovilizando enemigos
- **Silencing**: Tiempo silenciando enemigos  
- **Stunning**: Tiempo aturdiendo enemigos
- **Total CC**: Control de masas total aplicado

### Premios y Reconocimientos
- **MVP**: Jugador más valioso
- **Awards**: Premios específicos obtenidos (Most Siege Damage, Most Healing, etc.)

## 💾 Estructura de Archivos CSV

### structured_data.csv (Archivo Principal)
```csv
FileName,GameMode,Map,Version,Region,GameTime,Team,PlayerName,PlayerLevel,HeroName,HeroLevel,Award,Talents_L1,Talents_L4,Talents_L7,Talents_L10,Talents_L13,Talents_L16,Talents_L20,HeroKills,Assists,Takedowns,Deaths,MinionDamage,SummonDamage,StructureDamage,TotalSiegeDamage,HeroDamage,DamageTaken,HealingShielding,SelfHealing,Experience,SpentDead,RootingHeroes,SilenceHeroes,StunHeroes,CCHeroes,OnFire,SpellDamage,PhysicalDamage,MercDamage,MercCampCaptures,WatchTowerCaptures,TownKills,MinionKills,RegenGlobes,Winner
```

### Ejemplo de Registro
```csv
"2023-12-01 23.18.12 Ciudad argenta.StormReplay","aram","Ciudad argenta","2.55.4.91418","us","00:18:38","Blue","PlayerName",942,"Fenix",1,"mvp","FenixAdvancedTargeting","FenixTargetAcquired","FenixCombatAdvantage","FenixHeroicAbilityPurificationSalvo","FenixAdaniumShell","FenixArsenalOvercharge","FenixSecondaryFire",11,20,31,8,37306,0,15969,61058,50839,58777,0,0,19998,"00:04:09","00:00:00","00:00:00","00:00:00",0,"00:00:54",63848,56257,8161,2,0,1,45,27,"Yes"
```

## 🏗️ Estructura de Archivos del Proyecto

```
heroes-storm-replay-analyzer/
├── 📄 README.md                    # Documentación completa del proyecto
├── 🔧 .gitignore                   # Archivos excluidos del repositorio
├── ⚖️  LICENSE                     # Licencia MIT del proyecto
├── 🚀 heroesdecode.ps1            # Script principal de PowerShell
├── 📋 heroenames.txt               # Lista bilingüe de nombres de héroes
├── 📁 Saves/                      # Directorio para archivos .StormReplay (crear manualmente)
├── 📊 structured_data.csv         # Dataset principal estructurado (generado)
├── 📝 combined_output.csv         # Salida de texto legible (generado)
└── 📁 json_output/                # Archivos JSON individuales (generado)
    ├── 2023-12-01 23.18.12 Ciudad argenta.json
    ├── 2023-12-01 23.42.00 Caverna perdida.json
    └── ...
```

**Leyenda**:
- ✅ **Incluido en repositorio**: Archivos de código fuente y documentación
- 🚫 **NO incluido**: Archivos generados automáticamente y replays (por tamaño)

## ⚡ Rendimiento y Optimización

### Características de Rendimiento
- **Procesamiento secuencial**: Máxima compatibilidad con diferentes sistemas
- **Gestión de memoria**: Procesamiento archivo por archivo para evitar sobrecarga
- **Manejo de errores**: Continuación del procesamiento aunque fallen archivos individuales
- **Progreso en tiempo real**: Indicadores de progreso durante el procesamiento

### Tiempos Estimados
- **50 archivos**: ~2-3 minutos
- **100 archivos**: ~5-7 minutos  
- **500+ archivos**: ~20-30 minutos
- **Factores**: Depende del hardware y tamaño de los archivos .StormReplay

## 📊 Casos de Uso y Análisis

### Análisis de Rendimiento Personal
- Estadísticas de winrate por héroe
- Evolución del rendimiento a lo largo del tiempo
- Análisis de builds y selección de talentos más exitosas

### Análisis de Meta
- Héroes más populares por período
- Mapas con mejores winrates
- Tendencias de duración de partidas

### Análisis Avanzado
- Correlación entre selección de talentos y resultados
- Análisis de sinergia entre héroes en equipo
- Patrones de juego por modo (ARAM vs Ranked)

## 🔍 Troubleshooting

### Errores Comunes

#### Error: "heroes-decode no encontrado"
```powershell
# Verificar instalación
heroes-decode --version

# Si no está instalado, instalar via npm
npm install -g heroes-decode
```

#### Error: "Archivo .StormReplay corrupto"
```powershell
# El script continuará con otros archivos
# Verificar integridad del archivo específico
heroes-decode "archivo_problema.StormReplay"
```

#### Error: "Falta .NET Runtime"
```powershell
# Descargar e instalar .NET 8.0 Runtime
# https://dotnet.microsoft.com/download/dotnet/8.0
```

## 📝 Notas Importantes

### Configuración por Defecto
- ✅ **Procesamiento completo**: El script procesa **TODOS los archivos** por defecto
- 🔄 **Orden cronológico**: Los archivos se procesan del más antiguo al más nuevo
- 📊 **Dataset completo**: Cada archivo .StormReplay genera datos para 10 jugadores (5 por equipo)
- 💾 **Múltiples formatos**: Salida en CSV (análisis), JSON (detalle) y texto (legible)

### Consideraciones Técnicas
- **Dependencias externas**: Requiere heroes-decode y .NET Runtime instalados
- **Archivos grandes**: Los replays pueden ser de 1-5MB cada uno, planificar espacio en disco
- **Compatibilidad**: Funciona con todas las versiones de Heroes of the Storm
- **Escalabilidad**: Probado con datasets de 500+ partidas sin problemas

### Limitaciones Conocidas
- **Solo Windows**: El script PowerShell está optimizado para Windows
- **Archivos corruptos**: Archivos .StormReplay dañados se omiten automáticamente
- **Versiones antiguas**: Replays muy antiguos podrían tener campos limitados

## 🤝 Contribuir al Proyecto

### Cómo Contribuir
1. **Fork** el repositorio en GitHub
2. **Clona** tu fork localmente
3. **Crea** una rama para tu feature:
   ```bash
   git checkout -b feature/nueva-funcionalidad
   ```
4. **Desarrolla** y prueba tus cambios
5. **Commit** con mensajes descriptivos:
   ```bash
   git commit -m 'feat: Añadir análisis de winrate por mapa'
   ```
6. **Push** a tu rama:
   ```bash
   git push origin feature/nueva-funcionalidad
   ```
7. **Abre** un Pull Request detallado

### Áreas de Mejora
- 🔍 **Análisis adicionales**: Nuevas métricas y visualizaciones
- 🚀 **Optimización**: Mejoras de rendimiento en el procesamiento
- 🌐 **Compatibilidad**: Soporte para otros sistemas operativos
- 📊 **Exportación**: Nuevos formatos de salida (Excel, Parquet, etc.)
- 🔧 **UI/UX**: Interfaz gráfica opcional para el procesamiento

## 📜 Licencia

Este proyecto está licenciado bajo la **Licencia MIT** - ver el archivo [`LICENSE`](LICENSE) para detalles completos.

### Resumen de la Licencia
- ✅ **Uso comercial**: Permitido
- ✅ **Modificación**: Permitida  
- ✅ **Distribución**: Permitida
- ✅ **Uso privado**: Permitido
- ⚠️ **Responsabilidad**: Sin garantías, uso bajo tu propio riesgo

## 📞 Contacto y Soporte

### Reportar Problemas
- 🐛 **Bugs**: Abre un [Issue en GitHub](https://github.com/tu-usuario/heroes-storm-replay-analyzer/issues)
- 💡 **Sugerencias**: Propón nuevas funcionalidades via Issues
- ❓ **Preguntas**: Usa las Discussions de GitHub para consultas generales

### Comunidad
- 🎮 **Heroes of the Storm**: Únete a la comunidad de análisis de datos de HotS
- 📊 **Data Science**: Comparte tus análisis y visualizaciones
- 🔧 **Desarrollo**: Colabora en mejoras del código

---

**⭐ Si este proyecto te es útil, considera darle una estrella en GitHub!**

*Último update: Junio 2025 - Compatible con Heroes of the Storm 2.55+*
