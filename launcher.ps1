# Joven Saludable - App Prototipo Launcher
# PowerShell Script para abrir y gestionar el prototipo

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "     🚀 JOVEN SALUDABLE APP 📱" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Función para mostrar información del proyecto
function Show-ProjectInfo {
    Write-Host "📊 INFORMACIÓN DEL PROYECTO" -ForegroundColor Green
    Write-Host "• Nombre: Joven Saludable" -ForegroundColor White
    Write-Host "• Tipo: Red Social de Bienestar Mental" -ForegroundColor White
    Write-Host "• Pantallas: 18 pantallas completas" -ForegroundColor White
    Write-Host "• Tecnología: HTML, CSS, TailwindCSS" -ForegroundColor White
    Write-Host "• Generado por: Stitch.IA" -ForegroundColor White
    Write-Host ""
}

# Función para mostrar opciones de implementación
function Show-ImplementationOptions {
    Write-Host "🛠️ OPCIONES DE IMPLEMENTACIÓN" -ForegroundColor Magenta
    Write-Host "1. React Native + Expo (Recomendado para móvil)" -ForegroundColor Yellow
    Write-Host "2. Flutter (Cross-platform nativo)" -ForegroundColor Yellow
    Write-Host "3. Ionic + Capacitor (Híbrido)" -ForegroundColor Yellow
    Write-Host "4. Next.js PWA (Progressive Web App)" -ForegroundColor Yellow
    Write-Host "5. Vue.js + Quasar (Web/Mobile)" -ForegroundColor Yellow
    Write-Host ""
}

# Función para verificar si el archivo existe
function Test-PrototypeFiles {
    if (Test-Path "index.html") {
        Write-Host "✅ Archivo prototipo encontrado" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Archivo index.html no encontrado" -ForegroundColor Red
        Write-Host "Asegúrate de ejecutar este script en la carpeta del proyecto" -ForegroundColor Yellow
        return $false
    }
}

# Función principal
function Start-Prototype {
    if (Test-PrototypeFiles) {
        Write-Host "🚀 Iniciando prototipo..." -ForegroundColor Cyan
        
        # Intentar abrir con diferentes navegadores
        $browsers = @(
            "chrome.exe",
            "firefox.exe", 
            "msedge.exe",
            "iexplore.exe"
        )
        
        $opened = $false
        foreach ($browser in $browsers) {
            try {
                Start-Process $browser -ArgumentList (Resolve-Path "index.html").Path -ErrorAction Stop
                Write-Host "✅ Prototipo abierto en $browser" -ForegroundColor Green
                $opened = $true
                break
            } catch {
                continue
            }
        }
        
        if (-not $opened) {
            # Fallback: usar el navegador predeterminado
            Start-Process (Resolve-Path "index.html").Path
            Write-Host "✅ Prototipo abierto en navegador predeterminado" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "📖 CÓMO USAR EL PROTOTIPO:" -ForegroundColor Cyan
        Write-Host "• Haz clic en los botones para navegar entre pantallas" -ForegroundColor White
        Write-Host "• Observa el diseño responsive y las interacciones" -ForegroundColor White
        Write-Host "• Toma notas para la implementación" -ForegroundColor White
        Write-Host "• Usa F12 para inspeccionar el código" -ForegroundColor White
        Write-Host ""
    }
}

# Función para mostrar siguiente pasos
function Show-NextSteps {
    Write-Host "🎯 PRÓXIMOS PASOS RECOMENDADOS:" -ForegroundColor Blue
    Write-Host "1. Revisar y analizar todas las pantallas" -ForegroundColor White
    Write-Host "2. Elegir stack tecnológico (ver opciones arriba)" -ForegroundColor White
    Write-Host "3. Crear wireframes de navegación entre pantallas" -ForegroundColor White
    Write-Host "4. Definir la arquitectura del backend" -ForegroundColor White
    Write-Host "5. Configurar entorno de desarrollo" -ForegroundColor White
    Write-Host "6. Comenzar con MVP (Login, Feed básico, Perfil)" -ForegroundColor White
    Write-Host ""
}

# Función para crear estructura de proyecto
function New-ProjectStructure {
    $choice = Read-Host "¿Quieres crear estructura de proyecto para implementación? (y/n)"
    
    if ($choice -eq 'y' -or $choice -eq 'Y') {
        Write-Host "🏗️ Creando estructura de proyecto..." -ForegroundColor Yellow
        
        $frameworks = @{
            "1" = "react-native"
            "2" = "flutter" 
            "3" = "ionic"
            "4" = "nextjs-pwa"
            "5" = "vue-quasar"
        }
        
        Write-Host "Selecciona framework:"
        Show-ImplementationOptions
        $framework = Read-Host "Ingresa número (1-5)"
        
        if ($frameworks.ContainsKey($framework)) {
            $projectName = "joven-saludable-" + $frameworks[$framework]
            New-Item -ItemType Directory -Path $projectName -Force
            
            # Crear estructura básica
            $folders = @("src", "assets", "components", "screens", "services", "utils", "docs")
            foreach ($folder in $folders) {
                New-Item -ItemType Directory -Path "$projectName/$folder" -Force
            }
            
            # Crear README específico
            $readmeContent = @"
# Joven Saludable - $($frameworks[$framework].ToUpper())

## Setup del Proyecto

Proyecto generado para implementar la app Joven Saludable usando $($frameworks[$framework]).

### Estructura
- `/src` - Código fuente principal
- `/assets` - Imágenes, iconos, fuentes
- `/components` - Componentes reutilizables
- `/screens` - Pantallas de la aplicación
- `/services` - Servicios y APIs
- `/utils` - Utilidades y helpers
- `/docs` - Documentación

### Pantallas a Implementar
$(Get-ChildItem -Directory | Where-Object {$_.Name -ne $projectName} | ForEach-Object {"- $($_.Name)"} | Out-String)

### Siguiente Paso
1. Configurar entorno de desarrollo para $($frameworks[$framework])
2. Instalar dependencias necesarias
3. Comenzar implementación por pantalla Splash
"@
            
            $readmeContent | Out-File -FilePath "$projectName/README.md" -Encoding UTF8
            
            Write-Host "✅ Estructura creada en carpeta: $projectName" -ForegroundColor Green
            Write-Host "📁 Abre esa carpeta para comenzar el desarrollo" -ForegroundColor Cyan
        }
    }
}

# Ejecutar script principal
Clear-Host
Show-ProjectInfo
Show-ImplementationOptions
Start-Prototype
Show-NextSteps
New-ProjectStructure

Write-Host "🎉 ¡Proceso completado!" -ForegroundColor Green
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")