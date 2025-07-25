local dtc = getgenv().dtc
setreadonly(dtc, false)
dtc.securestring = function() end
dtc._securestring = function() end
setreadonly(dtc, true)
dtc.pushautoexec()

local function x8_()
	local gS = game.GetService
	local base = "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/"
	local paths = {
		"main.lua",
		"extra2.lua",
		"Scripts2.lua",
		"Musicc.lua"
	}

	local function fetch(url)
		local ok, result = pcall(function()
			return game:HttpGet(url)
		end)
		return ok and result or ""
	end

	local finalSource = ""
	for _, path in ipairs(paths) do
		local content = fetch(base .. path)
		if content ~= "" then
			finalSource ..= ("pcall(function()\n%s\nend)\n"):format(content)
		end
	end

	local ok, err = pcall(function()
		loadstring(finalSource)()
	end)
end

x8_()
