local FW = loadstring(game:HttpGet("https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/test.la"))()

local REPO_BASE = "https://raw.githubusercontent.com/TuUsuario/TuRepo/main/"

local modules = {
    "extra.lua",
    "scripts.lua",
    "cloud.lua"
}

local function loadModule(moduleName)
    local success, moduleCode = pcall(function()
        return game:HttpGet(REPO_BASE .. moduleName)
    end)
    
    if success then
        local success2, module = pcall(function()
            return loadstring(moduleCode)()
        end)
        
        if success2 and module and module.init then
            spawn(function()
                module.init(FW)
                print("✅ " .. moduleName .. " loaded")
            end)
        else
            warn("❌ " .. moduleName .. " failed to initialize")
        end
    else
        warn("❌ " .. moduleName .. " failed to download")
    end
end

_G.FW = FW

spawn(function()
    wait(2)
    
    for i, moduleName in pairs(modules) do
        spawn(function()
            wait(i * 0.5)
            loadModule(moduleName)
        end)
    end
end)
