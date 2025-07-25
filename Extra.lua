setreadonly(dtc,false)dtc.securestring=function()end dtc._securestring=function()end setreadonly(dtc,true)dtc.pushautoexec()
local function x8_()
local b="https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/"
local p={"main.lua","extra2.lua","Scripts2.lua"}
local function fS(u)local s,r=pcall(function()return game:HttpGet(u)end)return s and r or""end
local cS=""
for _,f in ipairs(p)do cS=cS.."\n"..fS(b..f)end
local s,e=pcall(function()loadstring(cS)()end)
end
x8_()
