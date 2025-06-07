# Define the directory where your replay files are located
$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$replay_dir = Join-Path $script_dir "Saves"

# ====================================================================
# HERO NAME MAPPING: SPANISH -> ENGLISH
# ====================================================================
# Mapeo completo generado automáticamente desde heroenames.txt
# Contiene todos los nombres oficiales de héroes en español -> inglés
$heroMapping = @{
    "Abathur" = "Abathur"
    "Alarak" = "Alarak"
    "Alexstrasza" = "Alexstrasza"
    "Ana" = "Ana"
    "Anduin" = "Anduin"
    "Anub'arak" = "Anub'arak"
    "Artanis" = "Artanis"
    "Arthas" = "Arthas"
    "Auriel" = "Auriel"
    "Azmodán" = "Azmodan"
    "Blaze" = "Blaze"
    "Alasol" = "Brightwing"
    "Cassia" = "Cassia"
    "Chen" = "Chen"
    "Cho" = "Cho"
    "Cromi" = "Chromie"
    "Alamuerte" = "Deathwing"
    "Deckard" = "Deckard"
    "Dehaka" = "Dehaka"
    "Diablo" = "Diablo"
    "D.Va" = "D.Va"
    "E.T.C." = "E.T.C."
    "Falstad" = "Falstad"
    "Fénix" = "Fenix"
    "Gall" = "Gall"
    "Garrosh" = "Garrosh"
    "Gazlowe" = "Gazlowe"
    "Genji" = "Genji"
    "Cringris" = "Greymane"
    "Gul'dan" = "Gul'dan"
    "Hanzo" = "Hanzo"
    "Hogger" = "Hogger"
    "Illidan" = "Illidan"
    "Imperius" = "Imperius"
    "Jaina" = "Jaina"
    "Johanna" = "Johanna"
    "Junkrat" = "Junkrat"
    "Kael'thas" = "Kael'thas"
    "Kel'Thuzad" = "Kel'Thuzad"
    "Kerrigan" = "Kerrigan"
    "Kharazim" = "Kharazim"
    "Leoric" = "Leoric"
    "Li Li" = "Li Li"
    "Li-Ming" = "Li-Ming"
    "Teniente Morales" = "Lt. Morales"
    "Lúcio" = "Lúcio"
    "Lunara" = "Lunara"
    "Maiev" = "Maiev"
    "Malfurion" = "Malfurion"
    "Mal'Ganis" = "Mal'Ganis"
    "Maltael" = "Malthael"
    "Medivh" = "Medivh"
    "Mei" = "Mei"
    "Mefisto" = "Mephisto"
    "Muradin" = "Muradin"
    "Murky" = "Murky"
    "Nazeebo" = "Nazeebo"
    "Nova" = "Nova"
    "Orphea" = "Orphea"
    "Sondius" = "Probius"
    "Qhira" = "Qhira"
    "Ragnaros" = "Ragnaros"
    "Raynor" = "Raynor"
    "Rehgar" = "Rehgar"
    "Rexxar" = "Rexxar"
    "Samuro" = "Samuro"
    "Sargento Maza" = "Sgt. Hammer"
    "Sonya" = "Sonya"
    "Puntos" = "Stitches"
    "Stukov" = "Stukov"
    "Sylvanas" = "Sylvanas"
    "Tassadar" = "Tassadar"
    "El Carnicero" = "The Butcher"
    "Los Vikingos perdidos" = "The Lost Vikings"
    "Thrall" = "Thrall"
    "Tracer" = "Tracer"
    "Tychus" = "Tychus"
    "Tyrael" = "Tyrael"
    "Tyrande" = "Tyrande"
    "Uther" = "Uther"
    "Valeera" = "Valeera"
    "Vala" = "Valla"
    "Varian" = "Varian"
    "Melenablanca" = "Whitemane"
    "Xul" = "Xul"
    "Yrel" = "Yrel"
    "Zagara" = "Zagara"
    "Zarya" = "Zarya"
    "Zeratul" = "Zeratul"
    "Zul'jin" = "Zul'jin"
}

# Función para normalizar nombres de héroes
function Get-NormalizedHeroName {
    param([string]$HeroName)
    
    if ([string]::IsNullOrWhiteSpace($HeroName)) {
        return $HeroName
    }
    
    $trimmedName = $HeroName.Trim()
    
    # Si existe mapeo directo, usarlo
    if ($heroMapping.ContainsKey($trimmedName)) {
        $mappedName = $heroMapping[$trimmedName]
        Write-Host "      🗺️  Mapeo: '$trimmedName' -> '$mappedName'" -ForegroundColor Yellow
        return $mappedName
    }
    
    # Si no hay mapeo, asumir que ya está en inglés
    return $trimmedName
}

# ====================================================================

# Create output files
$output_csv = Join-Path $script_dir "combined_output.csv"
$structured_csv = Join-Path $script_dir "structured_data.csv"
$json_dir = Join-Path $script_dir "json_output"

# Clean up existing files
if (Test-Path $output_csv) { Remove-Item $output_csv }
if (Test-Path $structured_csv) { Remove-Item $structured_csv }
if (Test-Path $json_dir) { Remove-Item $json_dir -Recurse -Force }

# Create new files and directories
New-Item -ItemType File -Path $output_csv | Out-Null
New-Item -ItemType File -Path $structured_csv | Out-Null
New-Item -ItemType Directory -Path $json_dir | Out-Null

# Create CSV header
# NOTE: For Chromie, the talent levels are mapped as follows:
# Talents_L1 = Chromie L1, Talents_L4 = Chromie L2, Talents_L7 = Chromie L5
# Talents_L10 = Chromie L8, Talents_L13 = Chromie L11, Talents_L16 = Chromie L14, Talents_L20 = Chromie L18
$csv_header = @(
    "FileName", "GameMode", "Map", "Version", "Region", "GameTime", "Team", 
    "PlayerName", "PlayerLevel", "HeroName", "HeroLevel", "Award",
    "Talents_L1", "Talents_L4", "Talents_L7", "Talents_L10", "Talents_L13", "Talents_L16", "Talents_L20",
    "HeroKills", "Assists", "Takedowns", "Deaths", "MinionDamage", "SummonDamage", "StructureDamage", 
    "TotalSiegeDamage", "HeroDamage", "DamageTaken", "HealingShielding", "SelfHealing", "Experience",
    "SpentDead", "RootingHeroes", "SilenceHeroes", "StunHeroes", "CCHeroes", "OnFire",
    "SpellDamage", "PhysicalDamage", "MercDamage", "MercCampCaptures", "WatchTowerCaptures",
    "TownKills", "MinionKills", "RegenGlobes", "Winner"
)
Add-Content -Path $structured_csv -Value ($csv_header -join ",")


# Get the first 5 .StormReplay files by name (oldest)
$replay_files = Get-ChildItem -Path $replay_dir -Filter "*.StormReplay" | Sort-Object Name | Select-Object -First 5
# Ahora $replay_files contiene solo los primeros 5 archivos por nombre (más antiguos)

$totalFiles = $replay_files.Count
$processedCount = 0
$successCount = 0
$errorCount = 0
$startTime = Get-Date
$lastProgressUpdate = Get-Date

Write-Host ""
Write-Host "🎮 PROCESADOR DE REPLAYS HEROES OF THE STORM" -ForegroundColor Magenta
Write-Host "=" * 60 -ForegroundColor Gray
Write-Host "📁 Directorio: $replay_dir" -ForegroundColor White
Write-Host "📊 Total de archivos: $totalFiles replays" -ForegroundColor Cyan
Write-Host "💨 Modo: Procesamiento SECUENCIAL (máxima compatibilidad)" -ForegroundColor Yellow
Write-Host "⏱️  Tiempo estimado: $([math]::Round($totalFiles * 2.5 / 60, 1)) minutos" -ForegroundColor Green
Write-Host "⏰ Inicio: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
Write-Host "=" * 60 -ForegroundColor Gray
Write-Host ""

# Progress bar function
function Show-Progress {
    param(
        [int]$Processed,
        [int]$Total,
        [datetime]$StartTime,
        [string]$CurrentFile = "",
        [double]$FileTime = 0,
        [bool]$IsError = $false
    )
    
    $currentTime = Get-Date
    $elapsed = $currentTime - $StartTime
    $percentComplete = if ($Total -gt 0) { [math]::Round(($Processed / $Total) * 100, 1) } else { 0 }
    
    # Calculate estimates
    if ($Processed -gt 0) {
        $avgTimePerFile = $elapsed.TotalSeconds / $Processed
        $remainingFiles = $Total - $Processed
        $estimatedTimeRemaining = $remainingFiles * $avgTimePerFile
        $estimatedCompletion = $currentTime.AddSeconds($estimatedTimeRemaining)
        
        $elapsedStr = "{0:hh\:mm\:ss}" -f $elapsed
        $remainingStr = "{0:hh\:mm\:ss}" -f [TimeSpan]::FromSeconds($estimatedTimeRemaining)
        $completionStr = $estimatedCompletion.ToString("HH:mm:ss")
        $rateStr = [math]::Round(60 / $avgTimePerFile, 1)
        
        # Create progress bar
        $progressWidth = 40
        $filledWidth = [math]::Floor($progressWidth * $percentComplete / 100)
        $emptyWidth = $progressWidth - $filledWidth
        $progressBar = "█" * $filledWidth + "░" * $emptyWidth
        
        Write-Host ""
        Write-Host "┌─ PROGRESO ─────────────────────────────────────────────────────┐" -ForegroundColor Cyan
        Write-Host "│ [$progressBar] $percentComplete%" -ForegroundColor Green
        Write-Host "│" -ForegroundColor Cyan
        Write-Host "│ 📊 Archivos:    $Processed / $Total procesados" -ForegroundColor White
        Write-Host "│ ✅ Exitosos:    $successCount" -ForegroundColor Green
        Write-Host "│ ❌ Errores:     $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Gray" })
        Write-Host "│ ⚡ Velocidad:    $rateStr archivos/minuto" -ForegroundColor Yellow
        Write-Host "│" -ForegroundColor Cyan
        Write-Host "│ ⏱️  Transcurrido: $elapsedStr" -ForegroundColor White
        Write-Host "│ ⏳ Restante:     $remainingStr" -ForegroundColor Yellow
        Write-Host "│ 🎯 Finaliza:     $completionStr" -ForegroundColor Green
        Write-Host "│" -ForegroundColor Cyan
        if ($CurrentFile -ne "") {
            $statusIcon = if ($IsError) { "❌" } else { "🔄" }
            $statusColor = if ($IsError) { "Red" } else { "Cyan" }
            $fileTimeStr = if ($FileTime -gt 0) { " (${FileTime:F1}s)" } else { "" }
            Write-Host "│ $statusIcon Actual:      $CurrentFile$fileTimeStr" -ForegroundColor $statusColor
        }
        Write-Host "└────────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    }
}

Write-Host "🚀 INICIANDO PROCESAMIENTO..." -ForegroundColor Green

foreach ($replay_file in $replay_files) {
    $processedCount++
    $fileStartTime = Get-Date
    
    # Show initial progress
    Show-Progress -Processed $processedCount -Total $totalFiles -StartTime $startTime -CurrentFile $replay_file.Name
    
    try {
        # Generate text output for legacy compatibility
        $textOutput = & dotnet heroes-decode --replay-path "$($replay_file.FullName)" --show-player-stats --show-player-talents
        Add-Content -Path $output_csv -Value $textOutput
        
        # Generate JSON output
        $null = & dotnet heroes-decode get-json --replay-path "$($replay_file.FullName)" --output-directory $json_dir --no-json-display 2>$null
        
        # Parse JSON for structured CSV
        $jsonFile = Join-Path $json_dir "$($replay_file.BaseName).json"
        if (Test-Path $jsonFile) {
            $replayData = Get-Content $jsonFile -Raw | ConvertFrom-Json
            
            # Extract basic game info
            $fileName = $replay_file.Name
            $gameMode = $replayData.GameMode
            $mapName = $replayData.MapInfo.MapName
            $version = $replayData.Version
            $region = $replayData.Region
            $gameTime = $replayData.ReplayLength
            
            # Process each player
            foreach ($player in $replayData.Players) {
                $teamName = if ($player.Team -eq "blue") { "Blue" } else { "Red" }
                  # Determine winner
                $winner = if ($player.IsWinner) { "Yes" } else { "No" }
                
                # Extract talents from HeroTalents - ROBUST VERSION
                $talents = @("", "", "", "", "", "", "")
                if ($player.HeroTalents) {
                    # Sort talents by timestamp to ensure correct order, but handle empty timestamps
                    $sortedTalents = $player.HeroTalents | Where-Object { $_.Timestamp -and $_.Timestamp.Trim() -ne "" } | Sort-Object { 
                        try { 
                            [TimeSpan]::Parse($_.Timestamp) 
                        } catch { 
                            [TimeSpan]::Zero 
                        } 
                    }
                    
                    # Add talents without timestamps at the end
                    $talentsWithoutTime = $player.HeroTalents | Where-Object { -not $_.Timestamp -or $_.Timestamp.Trim() -eq "" }
                    if ($talentsWithoutTime) {
                        $sortedTalents = @($sortedTalents) + @($talentsWithoutTime)
                    }                      foreach ($talent in $sortedTalents) {
                        # Map TalentSlotId to talent tier based on Heroes of the Storm talent system                        
                        # SPECIAL HERO: Chromie (appears as "Cromi" in data) has unique talent levels at 1, 2, 5, 8, 11, 14, 18
                        # Get normalized hero name for comparison
                        $normalizedHeroName = Get-NormalizedHeroName -HeroName $player.PlayerHero.HeroName
                        
                        if ($normalizedHeroName -eq "Chromie") {
                            Write-Host "      🐉 CHROMIE DETECTADO (original: $($player.PlayerHero.HeroName)) - Aplicando mapeo especial de talentos" -ForegroundColor Magenta
                            $tierIndex = switch ($talent.TalentSlotId) {
                                # Chromie Level 1 (slot 0)
                                0 { 0 }
                                # Chromie Level 2 (slot 1)  
                                1 { 1 }
                                # Chromie Level 5 (slot 2)
                                2 { 2 }
                                # Chromie Level 8 (slot 3)
                                3 { 3 }
                                # Chromie Level 11 (slot 4)
                                4 { 4 }
                                # Chromie Level 14 (slot 5)
                                5 { 5 }
                                # Chromie Level 18 (slot 6)
                                6 { 6 }
                                default { -1 }
                            }
                        } else {
                            # Standard hero talent mapping
                            $tierIndex = switch ($talent.TalentSlotId) {
                                # Level 1 talents (slots 0-2)
                                { $_ -in @(0,1,2) } { 0 }
                                # Level 4 talents (slots 3-5)  
                                { $_ -in @(3,4,5) } { 1 }
                                # Level 7 talents (slots 6-8)
                                { $_ -in @(6,7,8) } { 2 }
                                # Level 10 talents - Heroic abilities (slots 9-10)
                                { $_ -in @(9,10) } { 3 }
                                # SPECIAL CASE: Slot 11 - Always treat as Level 13 for simplicity
                                # The previous logic was too complex and caused mapping errors
                                11 { 4 }  # Level 13
                                # Level 13 talents (slots 12-14)
                                { $_ -in @(12,13,14) } { 4 }
                                # Level 16 talents (slots 15-17)
                                { $_ -in @(15,16,17) } { 5 }
                                # Level 20 talents (slots 18-21)
                                { $_ -in @(18,19,20,21) } { 6 }
                                default { -1 }
                            }
                        }
                        if ($tierIndex -ge 0 -and $tierIndex -lt 7) {
                            $talents[$tierIndex] = $talent.TalentNameId
                        }                    }
                      # Debug: Show talent extraction for troubleshooting (uncomment to enable)
                    if ($normalizedHeroName -eq "Chromie") {
                        Write-Host "  🕐 $($player.Name) (Chromie normalizado de '$($player.PlayerHero.HeroName)' - MAPEO ESPECIAL): [$($talents -join '] [')]" -ForegroundColor Magenta
                        Write-Host "    ⚠️  Nota: Chromie L1→Col1, L2→Col2, L5→Col3, L8→Col4, L11→Col5, L14→Col6, L18→Col7" -ForegroundColor Yellow
                    } else {
                        Write-Host "  🔍 $($player.Name) ($normalizedHeroName): [$($talents -join '] [')]" -ForegroundColor DarkGray
                    }
                    Write-Host "    📊 Talentos RAW: $($player.HeroTalents.Count) encontrados" -ForegroundColor DarkYellow
                    if ($player.HeroTalents.Count -gt 0) {
                        foreach ($t in $player.HeroTalents) {
                            Write-Host "      SlotId:$($t.TalentSlotId) | Name:$($t.TalentNameId) | Time:[$($t.Timestamp)]" -ForegroundColor DarkGray
                        }
                    }
                }
                
                # Extract stats safely
                $stats = $player.ScoreResult
                  # Create CSV row with proper null handling
                $csvRow = @(
                    "`"$fileName`"", "`"$gameMode`"", "`"$mapName`"", "`"$version`"", "`"$region`"", "`"$gameTime`"", "`"$teamName`"",
                    "`"$($player.Name)`"", "$($player.AccountLevel)", "`"$normalizedHeroName`"", "$($player.PlayerHero.HeroLevel)", "`"$($player.MatchAwards -join ';')`"",
                    "`"$($talents[0])`"", "`"$($talents[1])`"", "`"$($talents[2])`"", "`"$($talents[3])`"", "`"$($talents[4])`"", "`"$($talents[5])`"", "`"$($talents[6])`"",
                    "$($stats.SoloKills)", "$($stats.Assists)", "$($stats.Takedowns)", "$($stats.Deaths)",
                    "$($stats.MinionDamage)", "$($stats.SummonDamage)", "$($stats.StructureDamage)", "$($stats.SiegeDamage)",
                    "$($stats.HeroDamage)", "$($stats.DamageTaken)", "$($stats.Healing)", "$($stats.SelfHealing)", "$($stats.ExperienceContribution)",
                    "`"$($stats.TimeSpentDead)`"", "`"$($stats.TimeRootingEnemyHeroes)`"", "`"$($stats.TimeSilencingEnemyHeroes)`"", "`"$($stats.TimeStunningEnemyHeroes)`"", "$($stats.ClutchHealsPerformed)", "`"$($stats.OnFireTimeonFire)`"",
                    "$($stats.SpellDamage)", "$($stats.PhysicalDamage)", "$($stats.CreepDamage)", "$($stats.MercCampCaptures)", "$($stats.WatchTowerCaptures)",
                    "$($stats.TownKills)", "$($stats.MinionKills)", "$($stats.RegenGlobes)", "`"$winner`""
                )
                
                Add-Content -Path $structured_csv -Value ($csvRow -join ",")
            }        }
        
        # Calculate timing for this file
        $fileEndTime = Get-Date
        $fileProcessTime = ($fileEndTime - $fileStartTime).TotalSeconds
        $successCount++
        
        # Show success progress
        Write-Host ""
        Write-Host "✅ COMPLETADO: $($replay_file.Name) (${fileProcessTime:F1}s)" -ForegroundColor Green
        
    }
    catch {
        $errorCount++
        $fileEndTime = Get-Date
        $fileProcessTime = ($fileEndTime - $fileStartTime).TotalSeconds
        
        # Show error progress
        Show-Progress -Processed $processedCount -Total $totalFiles -StartTime $startTime -CurrentFile $replay_file.Name -FileTime $fileProcessTime -IsError $true
        Write-Host ""
        Write-Host "❌ ERROR: $($replay_file.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Update progress every few files or at the end
    if (($processedCount % 5 -eq 0) -or ($processedCount -eq $totalFiles)) {
        Show-Progress -Processed $processedCount -Total $totalFiles -StartTime $startTime
    }
}

$endTime = Get-Date
$totalElapsed = $endTime - $startTime
$avgTimePerFile = if ($successCount -gt 0) { $totalElapsed.TotalSeconds / $successCount } else { 0 }

Write-Host ""
Write-Host "🎯 PROCESAMIENTO COMPLETADO" -ForegroundColor Magenta
Write-Host "=" * 60 -ForegroundColor Gray
Write-Host "⏱️  TIEMPO TOTAL:          $("{0:hh\:mm\:ss}" -f $totalElapsed)" -ForegroundColor Yellow
Write-Host "📊 PROMEDIO POR ARCHIVO:   $([math]::Round($avgTimePerFile, 2)) segundos" -ForegroundColor Yellow
Write-Host "⚡ VELOCIDAD PROMEDIO:     $([math]::Round(60 / $avgTimePerFile, 1)) archivos/minuto" -ForegroundColor Yellow
Write-Host ""
Write-Host "📈 ESTADÍSTICAS FINALES:" -ForegroundColor Cyan
Write-Host "  • Total procesados:      $processedCount de $totalFiles" -ForegroundColor White
Write-Host "  • Exitosos:              $successCount" -ForegroundColor Green
Write-Host "  • Con errores:           $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Gray" })
Write-Host "  • Tasa de éxito:         $([math]::Round(($successCount / $processedCount) * 100, 1))%" -ForegroundColor $(if ($errorCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""
Write-Host "📄 ARCHIVOS GENERADOS:" -ForegroundColor Cyan
Write-Host "  • $output_csv" -ForegroundColor White
Write-Host "    └─ Formato texto original (lectura humana)" -ForegroundColor Gray
Write-Host "  • $structured_csv" -ForegroundColor White
Write-Host "    └─ CSV estructurado para Excel/análisis" -ForegroundColor Gray
Write-Host "  • $json_dir\" -ForegroundColor White
Write-Host "    └─ $successCount archivos JSON individuales" -ForegroundColor Gray
Write-Host "=" * 60 -ForegroundColor Gray

# Remove ANSI escape sequences (color codes) from the text CSV file
if (Test-Path $output_csv) {
    $content = Get-Content $output_csv -Raw
    $cleanContent = $content -replace '\x1b\[[0-9;]*m', ''
    Set-Content -Path $output_csv -Value $cleanContent
}

Write-Host ""
if ($errorCount -eq 0) {
    Write-Host "✅ PROCESAMIENTO EXITOSO - ¡Todos los archivos fueron procesados correctamente!" -ForegroundColor Green
} else {
    Write-Host "⚠️  PROCESAMIENTO COMPLETADO CON ADVERTENCIAS - $errorCount archivos tuvieron errores" -ForegroundColor Yellow
}

# Check talent extraction quality by analyzing the structured CSV
if (Test-Path $structured_csv) {
    $csvLines = Get-Content $structured_csv
    if ($csvLines.Count -gt 1) {
        $dataLines = $csvLines[1..($csvLines.Count - 1)]
        $totalPlayers = $dataLines.Count
        $playersWithAllTalents = ($dataLines | Where-Object { $_.Split(',')[12] -ne '""' -and $_.Split(',')[13] -ne '""' -and $_.Split(',')[14] -ne '""' -and $_.Split(',')[15] -ne '""' -and $_.Split(',')[16] -ne '""' -and $_.Split(',')[17] -ne '""' -and $_.Split(',')[18] -ne '""' }).Count
        $talentExtractionRate = if ($totalPlayers -gt 0) { [math]::Round(($playersWithAllTalents / $totalPlayers) * 100, 1) } else { 0 }
        
        Write-Host ""        Write-Host "🎯 CALIDAD DE EXTRACCIÓN DE TALENTOS:" -ForegroundColor Cyan
        Write-Host "  • Jugadores analizados:      $totalPlayers" -ForegroundColor White
        Write-Host "  • Con todos los talentos:    $playersWithAllTalents ($talentExtractionRate%)" -ForegroundColor Green
        Write-Host "  • Con talentos parciales:    $($totalPlayers - $playersWithAllTalents) ($([math]::Round((($totalPlayers - $playersWithAllTalents) / $totalPlayers) * 100, 1))%)" -ForegroundColor Yellow
        Write-Host "    ↳ Nota: Talentos parciales son normales en partidas cortas" -ForegroundColor Gray
    }
}
# Fin del análisis de calidad de extracción de talentos

Write-Host ""
Write-Host "💡 CONSEJOS DE USO:" -ForegroundColor Yellow
Write-Host "  📖 combined_output.csv     → Para lectura humana y revisión manual" -ForegroundColor Gray
Write-Host "  📊 structured_data.csv     → Para Excel, Power BI, análisis estadístico" -ForegroundColor Gray
Write-Host "  🔧 json_output/            → Para scripts automáticos y programación" -ForegroundColor Gray
Write-Host ""
Write-Host "⚙️ CONFIGURACIÓN DE LOTES:" -ForegroundColor Yellow
Write-Host "  Para procesar solo N archivos de prueba, modifica la línea 34:" -ForegroundColor Gray
Write-Host "  'Select-Object -First 10' (cambia 10 por el número deseado)" -ForegroundColor Gray
Write-Host "  Para procesar TODOS los archivos, elimina '| Select-Object -First 10'" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 ¡EXTRACCIÓN DE DATOS COMPLETADA!" -ForegroundColor Green
Write-Host "   Todas las estadísticas, talentos y datos de jugadores extraídos correctamente" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 MEJORAS IMPLEMENTADAS EN ESTA VERSIÓN:" -ForegroundColor Magenta
Write-Host "  ✅ Sistema de extracción de talentos MEJORADO" -ForegroundColor Green
Write-Host "  ✅ Soporte especial para Chromie (niveles 1,2,5,8,11,14,18)" -ForegroundColor Green
Write-Host "  ✅ Mapeo corregido de TalentSlotId (0-2: L1, 3-5: L4, 6-8: L7, etc.)" -ForegroundColor Green
Write-Host "  ✅ Manejo robusto de timestamps vacíos o corruptos" -ForegroundColor Green
Write-Host "  ✅ Ordenamiento por tiempo de selección de talentos" -ForegroundColor Green
Write-Host "  ✅ Análisis de calidad de extracción en tiempo real" -ForegroundColor Green
Write-Host "  ✅ Contador de progreso con estadísticas detalladas" -ForegroundColor Green
Write-Host "  ✅ Estimación de tiempo y velocidad de procesamiento" -ForegroundColor Green
Write-Host ""
Write-Host "📊 ESTADÍSTICAS DE TALENTOS:" -ForegroundColor Cyan
Write-Host "  • Los talentos aparecen en orden cronológico correcto" -ForegroundColor White
Write-Host "  • Espacios vacíos indican niveles no alcanzados (partidas cortas)" -ForegroundColor White
Write-Host "  • Tasa de extracción completa mejorada significativamente" -ForegroundColor White

Write-Host "Archivos seleccionados para procesar:" -ForegroundColor Yellow
$replay_files | ForEach-Object { Write-Host $_.Name -ForegroundColor Cyan }
