local SyntaxHighlighter = {}

local Colors = {
    keywords = "#569CD6",
    builtins = "#DCDCAA", 
    roblox = "#FFB454",
    strings = "#CE9178",
    numbers = "#B5CEA8",
    comments = "#6A9955",
    operators = "#D4D4D4",
    default = "#FFFFFF"
}

local Keywords = {
    "and", "break", "do", "else", "elseif", "end", "false", "for", 
    "function", "if", "in", "local", "nil", "not", "or", "repeat", 
    "return", "then", "true", "until", "while", "goto"
}

local Builtins = {
    "print", "warn", "error", "assert", "type", "tostring", "tonumber",
    "pairs", "ipairs", "next", "pcall", "xpcall", "getmetatable", "setmetatable",
    "rawget", "rawset", "rawequal", "rawlen", "select", "unpack", "pack",
    "loadstring", "load", "require", "module", "getfenv", "setfenv"
}

local RobloxAPI = {
    "game", "workspace", "script", "wait", "spawn", "delay", "tick",
    "Instance", "Vector3", "Vector2", "CFrame", "UDim2", "UDim", "Color3",
    "BrickColor", "Ray", "Region3", "Enum", "UserInputService", "RunService",
    "TweenService", "HttpService", "MarketplaceService", "Players", "Lighting"
}

local keywordSet = {}
for _, word in ipairs(Keywords) do keywordSet[word] = true end

local builtinSet = {}
for _, word in ipairs(Builtins) do builtinSet[word] = true end

local robloxSet = {}
for _, word in ipairs(RobloxAPI) do robloxSet[word] = true end

local function escapeRichText(text)
    return text:gsub("[<>&]", {
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ["&"] = "&amp;"
    })
end

local function colorText(text, color)
    return '<font color="' .. color .. '">' .. escapeRichText(text) .. '</font>'
end

function SyntaxHighlighter.highlight(code)
    if not code or code == "" then
        return ""
    end

    local result = ""
    local i = 1
    local len = #code

    while i <= len do
        local char = code:sub(i, i)
        
        if char == "-" and i < len and code:sub(i + 1, i + 1) == "-" then
            local commentStart = i
            local commentEnd = i
            
            if i + 3 <= len and code:sub(i + 2, i + 4) == "[[" then
                local bracketCount = 0
                local j = i + 2
                while j <= len and code:sub(j, j) == "[" do
                    bracketCount = bracketCount + 1
                    j = j + 1
                end
                
                local closingPattern = "]" .. string.rep("=", bracketCount - 2) .. "]"
                local closingStart = code:find(closingPattern, j, true)
                if closingStart then
                    commentEnd = closingStart + #closingPattern - 1
                else
                    commentEnd = len
                end
            else
                while commentEnd <= len and code:sub(commentEnd, commentEnd) ~= "\n" do
                    commentEnd = commentEnd + 1
                end
                commentEnd = commentEnd - 1
            end
            
            local comment = code:sub(commentStart, commentEnd)
            result = result .. colorText(comment, Colors.comments)
            i = commentEnd + 1
            
        elseif char == '"' then
            local stringStart = i
            i = i + 1
            while i <= len do
                if code:sub(i, i) == '"' then
                    i = i + 1
                    break
                elseif code:sub(i, i) == "\\" and i < len then
                    i = i + 2
                else
                    i = i + 1
                end
            end
            local str = code:sub(stringStart, i - 1)
            result = result .. colorText(str, Colors.strings)
            
        elseif char == "'" then
            local stringStart = i
            i = i + 1
            while i <= len do
                if code:sub(i, i) == "'" then
                    i = i + 1
                    break
                elseif code:sub(i, i) == "\\" and i < len then
                    i = i + 2
                else
                    i = i + 1
                end
            end
            local str = code:sub(stringStart, i - 1)
            result = result .. colorText(str, Colors.strings)
            
        elseif char == "[" and i < len and code:sub(i + 1, i + 1) == "[" then
            local stringStart = i
            local bracketCount = 0
            local j = i
            while j <= len and code:sub(j, j) == "[" do
                bracketCount = bracketCount + 1
                j = j + 1
            end
            
            local closingPattern = "]" .. string.rep("=", bracketCount - 2) .. "]"
            local closingStart = code:find(closingPattern, j, true)
            if closingStart then
                i = closingStart + #closingPattern
            else
                i = len + 1
            end
            local str = code:sub(stringStart, i - 1)
            result = result .. colorText(str, Colors.strings)
            
        elseif char:match("%d") then
            local numStart = i
            while i <= len do
                local c = code:sub(i, i)
                if c:match("[%d%.]") then
                    i = i + 1
                elseif c:lower() == "e" and i < len then
                    i = i + 1
                    if code:sub(i, i):match("[%+%-]") then
                        i = i + 1
                    end
                elseif numStart == i - 1 and c:lower() == "x" and code:sub(numStart, numStart) == "0" then
                    i = i + 1
                    while i <= len and code:sub(i, i):match("[%da-fA-F]") do
                        i = i + 1
                    end
                    break
                else
                    break
                end
            end
            local num = code:sub(numStart, i - 1)
            result = result .. colorText(num, Colors.numbers)
            
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
            
        elseif char:match("[%+%-%*/%%=%<>%(%)%{%}%[%];:,%.#~]") then
            local opStart = i
            if char == "=" and i < len and code:sub(i + 1, i + 1) == "=" then
                i = i + 2
            elseif char == "~" and i < len and code:sub(i + 1, i + 1) == "=" then
                i = i + 2
            elseif char == "<" and i < len and code:sub(i + 1, i + 1) == "=" then
                i = i + 2
            elseif char == ">" and i < len and code:sub(i + 1, i + 1) == "=" then
                i = i + 2
            elseif char == "." and i + 1 <= len and code:sub(i + 1, i + 1) == "." then
                i = i + 2
                if i <= len and code:sub(i, i) == "." then
                    i = i + 1
                end
            else
                i = i + 1
            end
            local op = code:sub(opStart, i - 1)
            result = result .. colorText(op, Colors.operators)
            
        else
            result = result .. char
            i = i + 1
        end
    end

    return result
end

function SyntaxHighlighter.highlightRealTime(textBox)
    if not textBox then return end
    
    local lastText = ""
    local isUpdating = false
    
    local function updateHighlighting()
        if isUpdating then return end
        isUpdating = true
        
        spawn(function()
            wait(0.1)
            
            if textBox.Text ~= lastText then
                lastText = textBox.Text
                local highlighted = SyntaxHighlighter.highlight(textBox.Text)
                
                if textBox.Text == lastText then
                    textBox.RichText = true
                    
                    local cursorPos = textBox.CursorPosition
                    textBox.Text = highlighted
                    
                    if cursorPos >= 0 then
                        spawn(function()
                            wait(0.05)
                            textBox.CursorPosition = cursorPos
                        end)
                    end
                end
            end
            
            isUpdating = false
        end)
    end
    
    textBox:GetPropertyChangedSignal("Text"):Connect(updateHighlighting)
    updateHighlighting()
end

return SyntaxHighlighter
