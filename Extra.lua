setreadonly(dtc,false)
dtc.securestring=function()end
dtc._securestring=function()end
setreadonly(dtc,true)
dtc.pushautoexec()
local function x8_()
local gS=game.GetService
local hS=gS(game,"HttpService")
local u1="https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/main.lua"
local u3="https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Scripts2.lua"
local function fS(u)local s,r=pcall(function()return game:HttpGet(u)end)return s and r or""end
local s1=fS(u1)
local s3=fS(u3)
local waitChunk="\nrepeat wait() until game:IsLoaded()\n"
local cS=s1..waitChunk..s3
local s,e=pcall(function()loadstring(cS)()end)
end
x8_()
