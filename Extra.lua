setreadonly(dtc,false)
dtc.securestring=function()end
dtc._securestring=function()end
setreadonly(dtc,true)
dtc.pushautoexec()
local function x8_()
    local gS=game.GetService
    local fS=function(u)local s,r=pcall(function()return game:HttpGet(u)end)return s and r or""end
    local u1="https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/main.lua"
    local u3="https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Scripts2.lua"
    local u4="https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Musicc.lua"
    local s1=fS(u1)
    local s2=fS(u3)
    local s3=fS(u4)
    local code=s1.."\n"..s2.."\n"..s3
    local s,e=pcall(function()loadstring(code)()end)
end
x8_()
