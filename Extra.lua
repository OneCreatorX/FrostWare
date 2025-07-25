setreadonly(dtc, false);
dtc.securestring = function() end
dtc._securestring = function() end
setreadonly(dtc, true);
dtc.pushautoexec();
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
		if s then return r else return "" end
	end

	local s1 = fS(u1)
	local s2 = fS(u2)
	local s3 = fS(u3)
	local s4 = fS(u4)

	local cS = s1 .. "\n" .. s2 .. "\n" .. s3 .. "\n" .. s4
	local s, e = pcall(function()
		loadstring(cS)()
	end)
end

x8_()   
