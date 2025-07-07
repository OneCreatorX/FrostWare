-- FrostWare V2 Module Loader
-- Este script inicializa la librería base y carga todos los módulos

print("🚀 FrostWare V2 Module Loader starting...")

-- Cargar la librería base
local FW = loadstring(game:HttpGet("https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/test.la"))()

-- Configuración de módulos
local REPO_BASE = "https://raw.githubusercontent.com/TuUsuario/TuRepo/main/"

local modules = {
    {
        name = "Extra",
        url = REPO_BASE .. "extra-module.lua",
        enabled = true,
        description = "System tools and utilities"
    },
    {
        name = "Scripts", 
        url = REPO_BASE .. "scripts-module.lua",
        enabled = true,
        description = "Local and cloud script management"
    },
    {
        name = "Cloud",
        url = REPO_BASE .. "cloud-module.lua", 
        enabled = false,
        description = "Cloud script browser and executor"
    }
}

-- Función para cargar un módulo individual
local function loadModule(moduleInfo)
    if not moduleInfo.enabled then 
        print("⏭️ Skipping disabled module: " .. moduleInfo.name)
        return 
    end
    
    print("📦 Loading module: " .. moduleInfo.name)
    
    local success, moduleCode = pcall(function()
        return game:HttpGet(moduleInfo.url)
    end)
    
    if success then
        print("✅ Downloaded: " .. moduleInfo.name)
        
        local success2, module = pcall(function()
            return loadstring(moduleCode)()
        end)
        
        if success2 and module and type(module) == "table" and module.init then
            spawn(function()
                local initSuccess, initError = pcall(function()
                    module.init(FW)
                end)
                
                if initSuccess then
                    print("🎉 " .. moduleInfo.name .. " module loaded successfully")
                    if moduleInfo.description then
                        print("   📝 " .. moduleInfo.description)
                    end
                else
                    warn("❌ Failed to initialize " .. moduleInfo.name .. " module: " .. tostring(initError))
                end
            end)
        else
            warn("❌ Invalid module structure for " .. moduleInfo.name .. " - missing init function")
        end
    else
        warn("❌ Failed to download " .. moduleInfo.name .. " module: " .. tostring(moduleCode))
    end
end

-- Función principal de carga
local function initializeModules()
    print("🔧 FrostWare base library loaded")
    print("📋 Found " .. #modules .. " modules to load")
    
    -- Esperar un momento para que la UI se inicialice completamente
    wait(2)
    
    -- Cargar módulos secuencialmente
    for i, moduleInfo in pairs(modules) do
        spawn(function()
            wait(i * 0.5) -- Espaciar la carga de módulos
            loadModule(moduleInfo)
        end)
    end
    
    -- Mensaje final
    spawn(function()
        wait(#modules * 0.5 + 2)
        print("🎯 Module loading process completed!")
        print("💡 Use the sidebar to navigate between features")
    end)
end

-- Hacer FW global para los módulos
_G.FW = FW

-- Inicializar el sistema
spawn(function()
    initializeModules()
end)

print("⚡ FrostWare V2 initialized - Loading modules...")
