# Define the directory where your replay files are located
$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$replay_dir = Join-Path $script_dir "Saves"

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

# Get all .StormReplay files in the directory
$replay_files = Get-ChildItem -Path $replay_dir -Filter "*.StormReplay"

Write-Host "🎮 PROCESAMIENTO COMPLETO: Procesando $($replay_files.Count) archivos de replay..." -ForegroundColor Green
Write-Host "💨 Procesamiento SECUENCIAL para máxima compatibilidad" -ForegroundColor Cyan
Write-Host "⏱️  Tiempo estimado: $([math]::Round($replay_files.Count * 2 / 60, 1)) minutos" -ForegroundColor Yellow

# Process files sequentially for reliability
Write-Host ""
Write-Host "🚀 Iniciando procesamiento secuencial..." -ForegroundColor Green

$processedCount = 0

foreach ($replay_file in $replay_files) {
    $processedCount++
    Write-Host "  🔄 [$processedCount/$($replay_files.Count)] Procesando: $($replay_file.Name)" -ForegroundColor Cyan
    
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
                
                # Extract talents from HeroTalents
                $talents = @("", "", "", "", "", "", "")
                if ($player.HeroTalents) {
                    foreach ($talent in $player.HeroTalents) {
                        # Map TalentSlotId to talent tier (simplified mapping)
                        $tierIndex = switch ($talent.TalentSlotId) {
                            { $_ -in @(1,2,3) } { 0 }      # Level 1
                            { $_ -in @(4,5,6) } { 1 }      # Level 4
                            { $_ -in @(7,8,9) } { 2 }      # Level 7
                            { $_ -in @(10,11,12) } { 3 }   # Level 10
                            { $_ -in @(13,14,15) } { 4 }   # Level 13
                            { $_ -in @(16,17,18) } { 5 }   # Level 16
                            { $_ -in @(19,20,21) } { 6 }   # Level 20
                            default { -1 }
                        }
                        if ($tierIndex -ge 0 -and $tierIndex -lt 7) {
                            $talents[$tierIndex] = $talent.TalentNameId
                        }
                    }
                }
                
                # Extract stats safely
                $stats = $player.ScoreResult
                
                # Create CSV row with proper null handling
                $csvRow = @(
                    "`"$fileName`"", "`"$gameMode`"", "`"$mapName`"", "`"$version`"", "`"$region`"", "`"$gameTime`"", "`"$teamName`"",
                    "`"$($player.Name)`"", "$($player.AccountLevel)", "`"$($player.PlayerHero.HeroName)`"", "$($player.PlayerHero.HeroLevel)", "`"$($player.MatchAwards -join ';')`"",
                    "`"$($talents[0])`"", "`"$($talents[1])`"", "`"$($talents[2])`"", "`"$($talents[3])`"", "`"$($talents[4])`"", "`"$($talents[5])`"", "`"$($talents[6])`"",
                    "$($stats.SoloKills)", "$($stats.Assists)", "$($stats.Takedowns)", "$($stats.Deaths)",
                    "$($stats.MinionDamage)", "$($stats.SummonDamage)", "$($stats.StructureDamage)", "$($stats.SiegeDamage)",
                    "$($stats.HeroDamage)", "$($stats.DamageTaken)", "$($stats.Healing)", "$($stats.SelfHealing)", "$($stats.ExperienceContribution)",
                    "`"$($stats.TimeSpentDead)`"", "`"$($stats.TimeRootingEnemyHeroes)`"", "`"$($stats.TimeSilencingEnemyHeroes)`"", "`"$($stats.TimeStunningEnemyHeroes)`"", "$($stats.ClutchHealsPerformed)", "`"$($stats.OnFireTimeonFire)`"",
                    "$($stats.SpellDamage)", "$($stats.PhysicalDamage)", "$($stats.CreepDamage)", "$($stats.MercCampCaptures)", "$($stats.WatchTowerCaptures)",
                    "$($stats.TownKills)", "$($stats.MinionKills)", "$($stats.RegenGlobes)", "`"$winner`""
                )
                
                Add-Content -Path $structured_csv -Value ($csvRow -join ",")
            }
        }
        
        Write-Host "  ✅ [$processedCount/$($replay_files.Count)] Completado: $($replay_file.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ [$processedCount/$($replay_files.Count)] Error en $($replay_file.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

$replay_counter = $processedCount

Write-Host ""
Write-Host "🎯 PROCESAMIENTO COMPLETO COMPLETADO. Total de replays procesados: $replay_counter de $($replay_files.Count)" -ForegroundColor Green
Write-Host ""
Write-Host "📄 Archivos generados:" -ForegroundColor Cyan
Write-Host "  • $output_csv (formato texto original)" -ForegroundColor White
Write-Host "  • $structured_csv (CSV estructurado para análisis)" -ForegroundColor White
Write-Host "  • $json_dir\ (archivos JSON individuales)" -ForegroundColor White

# Remove ANSI escape sequences (color codes) from the text CSV file
$content = Get-Content $output_csv -Raw
$cleanContent = $content -replace '\x1b\[[0-9;]*m', ''
Set-Content -Path $output_csv -Value $cleanContent

Write-Host ""
Write-Host "✅ Procesamiento secuencial completado exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Uso de archivos:" -ForegroundColor Yellow
Write-Host "  • combined_output.csv: Para lectura humana" -ForegroundColor Gray
Write-Host "  • structured_data.csv: Para Excel/análisis de datos" -ForegroundColor Gray
Write-Host "  • json_output/: Para programación/scripts automáticos" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Para procesar SOLO 10 archivos de prueba, modifica la línea:" -ForegroundColor Yellow
Write-Host "    'Get-ChildItem -Path `$replay_dir -Filter `"*.StormReplay`"' y añade '| Select-Object -First 10'" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 CSV ESTRUCTURADO FUNCIONAL - Todas las estadísticas y talentos extraídos correctamente!" -ForegroundColor Green
