---Creates a new SVG Element
---@param name any
---@param childs SVGElement
---@return SVGElement
function SVGElement(name, childs)
    childs = childs or {}
    ---@class SVGElement : Element
    ---@field [number] SVGElement|string
    local SVGElement = {}

    function SVGElement:addChild(el)
        table.insert(childs, el)
        return el
    end

    function SVGElement:toString()
        local attrs, inner = '', ''
        for key, value in pairs(childs) do
            if type(key) == "string" then
                attrs = attrs .. (' %s="%s"'):format(key:gsub("%_", "-"), value)
            elseif type(key) == "number" then
                if type(value) == "string" then
                    inner = inner .. value
                elseif type(value) == "table" and value.toString then
                    inner = inner .. value:toString()
                end
            end
        end
        return ('<%s%s>%s</%s>'):format(name, attrs, inner, name)
    end

    return SVGElement
end

function SVG(content)
    local self     = {}
    content.xmlns  = content.xmlns or "http://www.w3.org/2000/svg"
    content.width  = content.width or 200
    content.height = content.height or 200

    function self:toString()
        local attrs, childs = '', ''
        for key, value in pairs(content) do
            if type(key) == "string" then
                attrs = attrs .. (' %s="%s"'):format(key, value)
            elseif type(key) == "number" then
                if type(value) == "string" then
                    childs = childs .. value
                elseif type(value) == "table" and value.toString then
                    childs = childs .. value:toString()
                end
            end
        end
        return ('<?xml version="1.0" encoding="UTF-8"?><svg%s>%s</svg>'):format(attrs, childs)
    end

    function self:save(filename)
        local f = io.open(filename, "w")
        if not f then return end
        f:write(self:toString())
        f:close()
    end

    return self
end

---@class SVGRectElement : SVGElement
---@field x number
---@field y number
---@field width number
---@field height number
---@field rx number?
---@field ry number?

---Rectangle element
---@param params SVGRectElement
---@return SVGElement
function Rect(params)
    return SVGElement("rect", params)
end

---@class SVGCircleElement : SVGElement
---@field cx number
---@field cy number
---@field r number

---Circle element
---@param params SVGCircleElement
---@return SVGElement
function Circle(params)
    return SVGElement("circle", params)
end

---@class SVGEllipseElement : SVGElement
---@field cx number
---@field cy number
---@field rx number
---@field ry number

---Ellipse element
---@param params SVGEllipseElement
---@return SVGElement
function Ellipse(params)
    return SVGElement("ellipse", params)
end

---@class SVGLineElement : SVGElement
---@field x1 number
---@field y1 number
---@field x2 number
---@field y2 number

---Line element
---@param params SVGLineElement
---@return SVGElement
function Line(params)
    return SVGElement("line", params)
end

---@class SVGPoint
---@field x number
---@field y number

---@class SVGPointsElement : SVGElement
---@field points string|SVGPoint[]

local function points_to_string(points)
    if type(points) ~= "table" then return points end

    local coordinates = {}
    for _, point in ipairs(points) do
        if type(point) == "table" then
            coordinates[#coordinates + 1] = tostring(point.x) .. "," .. tostring(point.y)
        else
            coordinates[#coordinates + 1] = tostring(point)
        end
    end
    return table.concat(coordinates, " ")
end

local function points_element(name, params)
    params = params or {}
    if type(params.points) == "table" then
        local attributes = {}
        for key, value in pairs(params) do
            attributes[key] = value
        end
        attributes.points = points_to_string(params.points)
        params = attributes
    end
    return SVGElement(name, params)
end

---Polyline element
---@param params SVGPointsElement
---@return SVGElement
function Polyline(params)
    return points_element("polyline", params)
end

---Polygon element
---@param params SVGPointsElement
---@return SVGElement
function Polygon(params)
    return points_element("polygon", params)
end

---@class SVGPathElement : SVGElement
---@field d string
---@field path_length number?

---Path element
---@param params SVGPathElement
---@return SVGElement
function Path(params)
    return SVGElement("path", params)
end

local function text_element(name, params, text)
    params = params or {}
    if text ~= nil then
        local children = {}
        for key, value in pairs(params) do
            children[key] = value
        end
        children[#children + 1] = text
        params = children
    end
    return SVGElement(name, params)
end

---Text element
---@param params SVGElement
---@param text string|nil
---@return SVGElement
function Text(params, text)
    return text_element("text", params, text)
end

---Text span element
---@param params SVGElement
---@param text string|nil
---@return SVGElement
function TSpan(params, text)
    return text_element("tspan", params, text)
end

local function container_element(name, params)
    return SVGElement(name, params)
end

---@param params SVGElement
---@return SVGElement
function Group(params)
    return container_element("g", params)
end

---@param params SVGElement
---@return SVGElement
function Defs(params)
    return container_element("defs", params)
end

---@param params SVGElement
---@return SVGElement
function Symbol(params)
    return container_element("symbol", params)
end

---@param params SVGElement
---@return SVGElement
function Use(params)
    return container_element("use", params)
end

---@param params SVGElement
---@return SVGElement
function Image(params)
    return container_element("image", params)
end

---@param params SVGElement
---@return SVGElement
function ForeignObject(params)
    return container_element("foreignObject", params)
end

---@param params SVGElement
---@return SVGElement
function Anchor(params)
    return container_element("a", params)
end

---@param params SVGElement
---@return SVGElement
function Title(params)
    return container_element("title", params)
end

---@param params SVGElement
---@return SVGElement
function Desc(params)
    return container_element("desc", params)
end

---@param params SVGElement
---@return SVGElement
function Metadata(params)
    return container_element("metadata", params)
end

---@param params SVGElement
---@return SVGElement
function LinearGradient(params)
    return container_element("linearGradient", params)
end

---@param params SVGElement
---@return SVGElement
function RadialGradient(params)
    return container_element("radialGradient", params)
end

---@param params SVGElement
---@return SVGElement
function Stop(params)
    return container_element("stop", params)
end

---@param params SVGElement
---@return SVGElement
function ClipPath(params)
    return container_element("clipPath", params)
end

---@param params SVGElement
---@return SVGElement
function Mask(params)
    return container_element("mask", params)
end

---@param params SVGElement
---@return SVGElement
function Pattern(params)
    return container_element("pattern", params)
end

---@param params SVGElement
---@return SVGElement
function Marker(params)
    return container_element("marker", params)
end
