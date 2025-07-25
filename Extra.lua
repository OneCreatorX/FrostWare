setreadonly(dtc, false)
dtc.securestring = function() end
dtc._securestring = function() end
setreadonly(dtc, true)
dtc.pushautoexec()

local function x8_()
    local gS = game.GetService
    local hS = gS(game, "HttpService")

    local u1 = "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/main.lua"
    local u2 = "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/extra2.lua"
    local u3 = "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Scripts2.lua"
    local u4 = "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Musicc.lua"

    local function fS(u)
        local s, r = pcall(function()
            return game:HttpGet(u)
        end)
        return s and r or ""
    end

    local cS = table.concat({
        fS(u1),
        fS(u2),
        fS(u3),
        fS(u4)
    }, "\n")

    local success, err = pcall(function()
        loadstring(cS)()
    end)

    if not success then
        warn("[FW] Error ", err)
    end
end

x8_()
