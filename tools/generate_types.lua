#!/usr/bin/env lua
--[[
    generate_svgelement.lua
    Gera uma classe Lua "SVGElement" com hints LuaLS
    a partir de https://github.com/mdn/data/blob/main/css/properties.json

    Uso:
        lua generate_svgelement.lua                      -- baixa da internet
        lua generate_svgelement.lua caminho/local.json  -- usa arquivo local
]]

local http_ok, http = pcall(require, "socket.http")
local ltn12_ok, ltn12 = pcall(require, "ltn12")

-- ─────────────────────────────────────────────────────────────────────────────
-- Configuração
-- ─────────────────────────────────────────────────────────────────────────────
local URL = "https://raw.githubusercontent.com/mdn/data/main/css/properties.json"
local OUTPUT = "types.d.lua"

-- Grupos CSS que fazem sentido para SVG (filtro opcional).
-- Se preferir TODAS as propriedades, deixe a lista vazia.
local SVG_GROUPS = {
    ["CSS Animations"]                   = true,
    ["CSS Backgrounds and Borders"]      = true,
    ["CSS Basic User Interface"]         = true,
    ["CSS Box Model"]                    = true,
    ["CSS Box Alignment"]                = true,
    ["CSS Color"]                        = true,
    ["CSS Compositing and Blending"]     = true,
    ["CSS Conditional Rules"]            = true,
    ["CSS Containment"]                  = true,
    ["CSS Display"]                      = true,
    ["CSS Fill and Stroke"]              = true,
    ["CSS Filter Effects"]               = true,
    ["CSS Flexible Box Layout"]          = true,
    ["CSS Fonts"]                        = true,
    ["CSS Fragmentation"]                = true,
    ["CSS Images"]                       = true,
    ["CSS Inline"]                       = true,
    ["CSS Lists and Counters"]           = true,
    ["CSS Logical Properties"]           = true,
    ["CSS Masking"]                      = true,
    ["CSS Miscellaneous"]                = true,
    ["CSS Motion Path"]                  = true,
    ["CSS Overflow"]                     = true,
    ["CSS Painter"]                      = true, -- alias comum de Fill/Stroke
    ["CSS Positioned Layout"]            = true,
    ["CSS Scroll Snap"]                  = true,
    ["CSS Shapes"]                       = true,
    ["CSS Speech"]                       = true,
    ["CSS Syntax"]                       = true,
    ["CSS Table"]                        = true,
    ["CSS Text Decoration"]              = true,
    ["CSS Text"]                         = true,
    ["CSS Transforms"]                   = true,
    ["CSS Transitions"]                  = true,
    ["CSS Typed OM"]                     = true,
    ["CSS Values and Units"]             = true,
    ["CSS Writing Modes"]                = true,
    ["Filter Effects"]                   = true,
    ["SVG"]                              = true,
    ["Scalable Vector Graphics"]         = true,
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Utilitários
-- ─────────────────────────────────────────────────────────────────────────────
local function log(fmt, ...)
    io.stderr:write(("[generate] "):format() .. string.format(fmt, ...) .. "\n")
end

local function read_all(path)
    local f, err = io.open(path, "rb")
    if not f then return nil, err end
    local data = f:read("*a")
    f:close()
    return data
end

local function fetch_url(url)
    if not http_ok then
        return nil, "LuaSocket não instalado. Rode: luarocks install luasocket"
    end
    local chunks = {}
    local res, code = http.request{
        url = url,
        sink = ltn12.sink.table(chunks),
    }
    if not res then return nil, "Falha na requisição: " .. tostring(code) end
    return table.concat(chunks)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Parser JSON minimalista (suficiente para o formato do MDN)
-- Suporta: object, array, string, number, true/false/null
-- ─────────────────────────────────────────────────────────────────────────────
local JSON = {}

local function skip_ws(s, i)
    while i <= #s do
        local c = s:sub(i, i)
        if c == " " or c == "\t" or c == "\n" or c == "\r" then
            i = i + 1
        else
            break
        end
    end
    return i
end

local parse_value

local function parse_string(s, i)
    -- i aponta para a aspa de abertura
    local buf = {}
    i = i + 1
    while i <= #s do
        local c = s:sub(i, i)
        if c == '"' then
            return table.concat(buf), i + 1
        elseif c == "\\" then
            local n = s:sub(i + 1, i + 1)
            if n == "n" then buf[#buf + 1] = "\n"
            elseif n == "t" then buf[#buf + 1] = "\t"
            elseif n == "r" then buf[#buf + 1] = "\r"
            elseif n == "b" then buf[#buf + 1] = "\b"
            elseif n == "f" then buf[#buf + 1] = "\f"
            elseif n == "/" then buf[#buf + 1] = "/"
            elseif n == '"' then buf[#buf + 1] = '"'
            elseif n == "\\" then buf[#buf + 1] = "\\"
            elseif n == "u" then
                local hex = s:sub(i + 2, i + 5)
                local cp = tonumber(hex, 16) or 0
                -- UTF-8 encode simples (BMP only)
                if cp < 0x80 then
                    buf[#buf + 1] = string.char(cp)
                elseif cp < 0x800 then
                    buf[#buf + 1] = string.char(
                        0xC0 + math.floor(cp / 0x40),
                        0x80 + (cp % 0x40)
                    )
                else
                    buf[#buf + 1] = string.char(
                        0xE0 + math.floor(cp / 0x1000),
                        0x80 + (math.floor(cp / 0x40) % 0x40),
                        0x80 + (cp % 0x40)
                    )
                end
                i = i + 4
            else
                buf[#buf + 1] = n
            end
            i = i + 2
        else
            buf[#buf + 1] = c
            i = i + 1
        end
    end
    error("String JSON não terminada")
end

local function parse_number(s, i)
    local j = i
    while j <= #s and s:sub(j, j):match("[%d%.eE%+%-]") do
        j = j + 1
    end
    local num = tonumber(s:sub(i, j - 1))
    return num, j
end

local function parse_array(s, i)
    local arr = {}
    i = skip_ws(s, i + 1)
    if s:sub(i, i) == "]" then return arr, i + 1 end
    while true do
        local v
        v, i = parse_value(s, i)
        arr[#arr + 1] = v
        i = skip_ws(s, i)
        local c = s:sub(i, i)
        if c == "," then
            i = skip_ws(s, i + 1)
        elseif c == "]" then
            return arr, i + 1
        else
            error("Esperava ',' ou ']' em array JSON, achei: " .. c)
        end
    end
end

local function parse_object(s, i)
    local obj = {}
    i = skip_ws(s, i + 1)
    if s:sub(i, i) == "}" then return obj, i + 1 end
    while true do
        i = skip_ws(s, i)
        if s:sub(i, i) ~= '"' then
            error("Esperava string key em objeto JSON, achei: " .. s:sub(i, i))
        end
        local key
        key, i = parse_string(s, i)
        i = skip_ws(s, i)
        if s:sub(i, i) ~= ":" then error("Esperava ':' em objeto JSON") end
        i = skip_ws(s, i + 1)
        local val
        val, i = parse_value(s, i)
        obj[key] = val
        i = skip_ws(s, i)
        local c = s:sub(i, i)
        if c == "," then
            i = skip_ws(s, i + 1)
        elseif c == "}" then
            return obj, i + 1
        else
            error("Esperava ',' ou '}' em objeto JSON, achei: " .. c)
        end
    end
end

parse_value = function(s, i)
    i = skip_ws(s, i)
    local c = s:sub(i, i)
    if c == "{" then return parse_object(s, i) end
    if c == "[" then return parse_array(s, i) end
    if c == '"' then return parse_string(s, i) end
    if c == "t" and s:sub(i, i + 3) == "true"  then return true,  i + 4 end
    if c == "f" and s:sub(i, i + 4) == "false" then return false, i + 5 end
    if c == "n" and s:sub(i, i + 3) == "null"  then return nil,   i + 4 end
    return parse_number(s, i)
end

function JSON.decode(str)
    local v
    v = parse_value(str, 1)
    return v
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Helpers de formatação
-- ─────────────────────────────────────────────────────────────────────────────

-- Converte nome CSS para nome seguro de campo Lua
-- "border-top-width" -> "border_top_width"
local function css_to_lua_field(name)
    return (name:gsub("%-", "_"))
end

-- Escapa texto para comentário Lua (remove quebras de linha)
local function comment_safe(s)
    return tostring(s):gsub("[\r\n]+", " ")
end

-- Limita um comentário a N caracteres
local function truncate(s, n)
    s = comment_safe(s)
    if #s > n then
        return s:sub(1, n - 3) .. "..."
    end
    return s
end

-- Escolhe "tipo Lua" heurístico baseado no status/syntax
local function infer_lua_type(prop)
    local syn = prop.syntax or ""
    if syn:find("<integer>") and not syn:find("|") and not syn:find("<length") then
        return "integer|string|nil"
    end
    if syn:find("<number>") or syn:find("<percentage>") or syn:find("<length") then
        return "number|string|nil"
    end
    return "string|nil"
end

-- Verifica se a propriedade é aplicável a SVG
local function applies_to_svg(name, prop)
    -- 1) Extensões de fabricante (-ms-, -moz-, -webkit-) → ignora
    if name:match("^%-") then return false end

    -- 2) Custom properties → ignora
    if name:match("^%-%-") then return false end

    -- 3) Filtro por grupo (se configurado)
    if next(SVG_GROUPS) ~= nil then
        local ok = false
        for _, g in ipairs(prop.groups or {}) do
            if SVG_GROUPS[g] then ok = true; break end
        end
        if not ok then return false end
    end

    -- 4) Appliesto: aceita tudo exceto coisas claramente não-SVG
    local a = prop.appliesto or ""
    if a:find("^table") or a:find("^ruby") then return false end

    return true
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Geração do código Lua
-- ─────────────────────────────────────────────────────────────────────────────
local function generate_class(props)
    local names = {}
    for name in pairs(props) do
        names[#names + 1] = name
    end
    table.sort(names)

    local lines = {}
    local function out(s) lines[#lines + 1] = s end

    -- Cabeçalho
    out("--!strict")
    out("--[[")
    out("    ─────────────────────────────────────────────────────────────")
    out("    Classe com hints LuaLS gerada automaticamente a partir de:")
    out("    https://github.com/mdn/data/blob/main/css/properties.json")
    out("")
    out("    Representa as propriedades de estilo aplicáveis a elementos SVG.")
    out("    Cada campo corresponde a uma propriedade CSS (nome kebab-case")
    out("    convertido para snake_case).")
    out("")
    out("    NÃO EDITE MANUALMENTE — regenere com generate_svgelement.lua")
    out("    ─────────────────────────────────────────────────────────────")
    out("]]")
    out("---@meta")
    out("")
    out("---@class Element")
    out("---@field tag string?             Tag do elemento SVG (ex.: 'rect')")
    out("---@field id string?              Atributo id")
    out("---@field class string?           Atributo class")

    local count = 0
    local by_group = {}

    for _, name in ipairs(names) do
        local prop = props[name]
        if applies_to_svg(name, prop) then
            count = count + 1
            local field = css_to_lua_field(name)
            local lua_type = infer_lua_type(prop)

            -- ── Documentação (SOMENTE tags válidas do LuaLS) ─────────────
            -- O bloco de comentários precisa ficar COLADO no ---@field
            -- abaixo, sem linha em branco no meio.
            out(("--- %s"):format(name))

            if prop.syntax and prop.syntax ~= "" then
                out(("--- Sintaxe: `%s`"):format(truncate(prop.syntax, 120)))
            end

            if prop.initial ~= nil then
                local init = prop.initial
                if type(init) == "table" then
                    init = table.concat(init, ", ")
                end
                out(("--- Valor inicial: `%s`"):format(truncate(init, 80)))
            end

            if prop.inherited ~= nil then
                out(("--- Herdado: %s"):format(tostring(prop.inherited)))
            end

            if prop.status and prop.status ~= "standard" then
                out(("--- Status: %s"):format(prop.status))
            end

            if prop.mdn_url then
                -- @see é uma tag válida do LuaLS (para referências).
                out(("---@see %s"):format(prop.mdn_url))
            end

            if prop.groups and #prop.groups > 0 then
                out(("--- Grupos: %s"):format(table.concat(prop.groups, ", ")))
                for _, g in ipairs(prop.groups) do
                    by_group[g] = (by_group[g] or 0) + 1
                end
            end

            -- ── Campo (SEM linha em branco antes) ────────────────────────
            out(("---@field %s %s"):format(field, lua_type))
        end
    end

    -- Métodos utilitários (mesmos de antes)
    out("---@return SVGElement")
    out("local function new()")
    out("    local self = setmetatable({}, { __index = SVGElement })")
    out("    return self")
    out("end")
    out("")
    out("---Define uma propriedade de estilo")
    out("---@param name string  Nome CSS (ex.: 'fill', 'stroke-width')")
    out("---@param value string|number")
    out("---@return SVGElement")
    out("function SVGElement:set(name, value)")
    out("    local key = name:gsub('%-', '_')")
    out("    self[key] = value")
    out("    return self")
    out("end")
    out("")
    out("---Serializa em string de atributo style")
    out("---@return string")
    out("function SVGElement:toStyleString()")
    out("    local parts = {}")
    out("    for k, v in pairs(self) do")
    out("        if type(v) ~= 'function' and k ~= 'tag' and k ~= 'id' and k ~= 'class' then")
    out("            local css = k:gsub('_', '-')")
    out("            parts[#parts + 1] = css .. ':' .. tostring(v)")
    out("        end")
    out("    end")
    out("    return table.concat(parts, '; ')")
    out("end")
    out("")
    out("return { new = new, SVGElement = SVGElement }")

    log("Total de propriedades geradas: %d", count)
    local groups_sorted = {}
    for g in pairs(by_group) do groups_sorted[#groups_sorted + 1] = g end
    table.sort(groups_sorted)
    for _, g in ipairs(groups_sorted) do
        log("  • %-40s %d", g, by_group[g])
    end

    return table.concat(lines, "\n") .. "\n"
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Main
-- ─────────────────────────────────────────────────────────────────────────────
local function main()
    local arg = arg or {}
    local json_text

    if arg[1] then
        log("Lendo arquivo local: %s", arg[1])
        local err
        json_text, err = read_all(arg[1])
        if not json_text then
            log("Erro: %s", err)
            os.exit(1)
        end
    else
        log("Baixando %s ...", URL)
        local err
        json_text, err = fetch_url(URL)
        if not json_text then
            log("Erro: %s", err)
            log("Dica: baixe manualmente e passe o caminho como argumento.")
            os.exit(1)
        end
    end

    log("Parseando JSON (%d bytes)...", #json_text)
    local ok, props = pcall(JSON.decode, json_text)
    if not ok then
        log("Erro no parse JSON: %s", props)
        os.exit(1)
    end

    log("Gerando classe SVGElement...")
    local lua_code = generate_class(props)

    local f, err = io.open(OUTPUT, "wb")
    if not f then
        log("Erro ao escrever %s: %s", OUTPUT, err)
        os.exit(1)
    end
    f:write(lua_code)
    f:close()
    log("✔ Arquivo gerado: %s (%d bytes)", OUTPUT, #lua_code)
end

main()