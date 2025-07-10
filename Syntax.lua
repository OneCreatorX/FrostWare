local SyntaxColors = {
    keywords = {
        color = Color3.fromRGB(86, 156, 214),
        words = {
            "and", "break", "do", "else", "elseif", "end", "false", "for", 
            "function", "if", "in", "local", "nil", "not", "or", "repeat", 
            "return", "then", "true", "until", "while", "goto"
        }
    },
    
    builtins = {
        color = Color3.fromRGB(220, 220, 170),
        words = {
            "print", "warn", "error", "assert", "type", "tostring", "tonumber",
            "pairs", "ipairs", "next", "pcall", "xpcall", "getmetatable", "setmetatable",
            "rawget", "rawset", "rawequal", "rawlen", "select", "unpack", "pack",
            "loadstring", "load", "require", "module", "getfenv", "setfenv"
        }
    },
    
    roblox = {
        color = Color3.fromRGB(255, 180, 84),
        words = {
            "game", "workspace", "script", "wait", "spawn", "delay", "tick",
            "Instance", "Vector3", "Vector2", "CFrame", "UDim2", "UDim", "Color3",
            "BrickColor", "Ray", "Region3", "Enum", "UserInputService", "RunService",
            "TweenService", "HttpService", "MarketplaceService", "Players", "Lighting"
        }
    },
    
    strings = {
        color = Color3.fromRGB(206, 145, 120),
        patterns = {
            '"[^"]*"',
            "'[^']*'",
            '%[%[.-%]%]'
        }
    },
    
    numbers = {
        color = Color3.fromRGB(181, 206, 168),
        patterns = {
            '%d+%.?%d*[eE]?[%+%-]?%d*',
            '0[xX]%x+'
        }
    },
    
    comments = {
        color = Color3.fromRGB(106, 153, 85),
        patterns = {
            '%-%-[^\n]*',
            '%-%-(%[=*%[).-(%]=*%])'
        }
    },
    
    operators = {
        color = Color3.fromRGB(212, 212, 212),
        words = {
            "+", "-", "*", "/", "%", "^", "#", "==", "~=", "<=", ">=", "<", ">", 
            "=", "(", ")", "{", "}", "[", "]", ";", ":", ",", ".", "..", "..."
        }
    },
    
    default = Color3.fromRGB(255, 255, 255)
}

return SyntaxColors
