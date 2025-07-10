-- FrostWare Syntax Highlighter
local SyntaxHighlighter = {}

-- Colores para diferentes tipos de tokens
local Colors = {
    keywords = "#569CD6",      -- Azul para palabras clave
    builtins = "#DCDCAA",      -- Amarillo para funciones built-in
    roblox = "#FFB454",        -- Naranja para APIs de Roblox
    strings = "#CE9178",       -- Marrón claro para strings
    numbers = "#B5CEA8",       -- Verde claro para números
    comments = "#6A9955",      -- Verde para comentarios
    operators = "#D4D4D4",     -- Gris claro para operadores
    default = "#FFFFFF"        -- Blanco por defecto
}

-- Palabras clave de Lua
local Keywords = {
    "and", "break", "do", "else", "elseif", "end", "false", "for", 
    "function", "if", "in", "local", "nil", "not", "or", "repeat", 
    "return", "then", "true", "until", "while", "goto"
}

-- Funciones built-in de Lua
local Builtins = {
    "print", "warn", "error", "assert", "type", "tostring", "tonumber",
    "pairs", "ipairs", "next", "pcall", "xpcall", "getmetatable", "setmetatable",
    "rawget", "rawset", "rawequal", "rawlen", "select", "unpack", "pack",
    "loadstring", "load", "require", "module"
}

-- APIs específicas de Roblox
local RobloxAPI = {
    "game", "workspace", "script", "wait", "spawn", "delay", "tick",
    "Instance", "Vector3", "Vector2", "CFrame", "UDim2", "UDim", "Color3",
    "BrickColor", "Ray", "Region3", "Enum", "UserInputService", "RunService",
    "TweenService", "HttpService", "Players", "Lighting"
}

-- Crear sets para búsqueda rápida
local keywordSet = {}
for _, word in ipairs(Keywords) do keywordSet[word] = true end

local builtinSet = {}
for _, word in ipairs(Builtins) do builtinSet[word] = true end

local robloxSet = {}
for _, word in ipairs(RobloxAPI) do robloxSet[word] = true end

-- Función para escapar caracteres especiales en RichText
local function escapeRichText(text)
    return text:gsub("[<>&]", {
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ["&"] = "&amp;"
    })
end

-- Función para colorear texto
local function colorText(text, color)
    return '<font color="' .. color .. '">' .. escapeRichText(text) .. '</font>'
end

-- Función principal de highlighting
function SyntaxHighlighter.highlight(code)
    if not code or code == "" then
        return ""
    end
    
    local result = ""
    local i = 1
    local len = #code
    
    while i <= len do
        local char = code:sub(i, i)
        
        -- Comentarios de línea
        if char == "-" and i < len and code:sub(i + 1, i + 1) == "-" then
            local commentStart = i
            while i <= len and code:sub(i, i) ~= "\n" do
                i = i + 1
            end
            local comment = code:sub(commentStart, i - 1)
            result = result .. colorText(comment, Colors.comments)
            
        -- Strings con comillas dobles
        elseif char == '"' then
            local stringStart = i
            i = i + 1
            while i <= len and code:sub(i, i) ~= '"' do
                if code:sub(i, i) == "\\" then
                    i = i + 1 -- Saltar carácter escapado
                end
                i = i + 1
            end
            if i <= len then i = i + 1 end -- Incluir comilla de cierre
            local str = code:sub(stringStart, i - 1)
            result = result .. colorText(str, Colors.strings)
            
        -- Strings con comillas simples
        elseif char == "'" then
            local stringStart = i
            i = i + 1
            while i <= len and code:sub(i, i) ~= "'" do
                if code:sub(i, i) == "\\" then
                    i = i + 1 -- Saltar carácter escapado
                end
                i = i + 1
            end
            if i <= len then i = i + 1 end -- Incluir comilla de cierre
            local str = code:sub(stringStart, i - 1)
            result = result .. colorText(str, Colors.strings)
            
        -- Números
        elseif char:match("%d") then
            local numStart = i
            while i <= len and code:sub(i, i):match("[%d%.]") do
                i = i + 1
            end
            local num = code:sub(numStart, i - 1)
            result = result .. colorText(num, Colors.numbers)
            
        -- Identificadores y palabras clave
        elseif char:match("[%a_]") then
            local wordStart = i
            while i <= len and code:sub(i, i):match("[%w_]") do
                i = i + 1
            end
            local word = code:sub(wordStart, i - 1)
            
            if keywordSet[word] then
                result = result .. colorText(word, Colors.keywords)
            elseif builtinSet[word] then
                result = result .. colorText(word, Colors.builtins)
            elseif robloxSet[word] then
                result = result .. colorText(word, Colors.roblox)
            else
                result = result .. escapeRichText(word)
            end
            
        -- Operadores
        elseif char:match("[%+%-%*/%%=%<>%(%)%{%}%[%];:,%.#]") then
            result = result .. colorText(char, Colors.operators)
            i = i + 1
            
        -- Otros caracteres (espacios, saltos de línea, etc.)
        else
            result = result .. char
            i = i + 1
        end
    end
    
    return result
end

return SyntaxHighlighter
