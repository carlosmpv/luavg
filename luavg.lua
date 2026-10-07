local SVG = {}

local function serialize_child(value)
    if type(value) == "string" then
        return value
    elseif type(value) == "table" then
        if type(value.toString) == "function" then
            return value:toString()
        end

        local children = {}
        for _, child in ipairs(value) do
            children[#children + 1] = serialize_child(child)
        end
        return table.concat(children)
    end
    return ""
end

---Creates a new SVG Element
---@param name any
---@param childs SVGElement
---@return SVGElement
function SVG.Element(name, childs)
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
            end
        end
        for _, child in ipairs(childs) do
            inner = inner .. serialize_child(child)
        end
        return ('<%s%s>%s</%s>'):format(name, attrs, inner, name)
    end

    return SVGElement
end

function SVG.Document(content)
    local self     = {}
    content.xmlns  = content.xmlns or "http://www.w3.org/2000/svg"
    content.width  = content.width or 200
    content.height = content.height or 200

    function self:toString()
        local attrs, childs = '', ''
        for key, value in pairs(content) do
            if type(key) == "string" then
                attrs = attrs .. (' %s="%s"'):format(key, value)
            end
        end
        for _, child in ipairs(content) do
            childs = childs .. serialize_child(child)
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
function SVG.Rect(params)
    return SVG.Element("rect", params)
end

---@class SVGCircleElement : SVGElement
---@field cx number
---@field cy number
---@field r number

---Circle element
---@param params SVGCircleElement
---@return SVGElement
function SVG.Circle(params)
    return SVG.Element("circle", params)
end

---@class SVGEllipseElement : SVGElement
---@field cx number
---@field cy number
---@field rx number
---@field ry number

---Ellipse element
---@param params SVGEllipseElement
---@return SVGElement
function SVG.Ellipse(params)
    return SVG.Element("ellipse", params)
end

---@class SVGLineElement : SVGElement
---@field x1 number
---@field y1 number
---@field x2 number
---@field y2 number

---Line element
---@param params SVGLineElement
---@return SVGElement
function SVG.Line(params)
    return SVG.Element("line", params)
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
    return SVG.Element(name, params)
end

---Polyline element
---@param params SVGPointsElement
---@return SVGElement
function SVG.Polyline(params)
    return points_element("polyline", params)
end

---Polygon element
---@param params SVGPointsElement
---@return SVGElement
function SVG.Polygon(params)
    return points_element("polygon", params)
end

---@class SVGPathElement : SVGElement
---@field d string
---@field path_length number?

---Path element
---@param params SVGPathElement
---@return SVGElement
function SVG.Path(params)
    return SVG.Element("path", params)
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
    return SVG.Element(name, params)
end

---Text element
---@param params SVGElement
---@param text string|nil
---@return SVGElement
function SVG.Text(params, text)
    return text_element("text", params, text)
end

---Text span element
---@param params SVGElement
---@param text string|nil
---@return SVGElement
function SVG.TSpan(params, text)
    return text_element("tspan", params, text)
end

local function container_element(name, params)
    return SVG.Element(name, params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Group(params)
    return container_element("g", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Defs(params)
    return container_element("defs", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Symbol(params)
    return container_element("symbol", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Use(params)
    return container_element("use", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Image(params)
    return container_element("image", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.ForeignObject(params)
    return container_element("foreignObject", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Anchor(params)
    return container_element("a", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Title(params)
    return container_element("title", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Desc(params)
    return container_element("desc", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Metadata(params)
    return container_element("metadata", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.LinearGradient(params)
    return container_element("linearGradient", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.RadialGradient(params)
    return container_element("radialGradient", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Stop(params)
    return container_element("stop", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.ClipPath(params)
    return container_element("clipPath", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Mask(params)
    return container_element("mask", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Pattern(params)
    return container_element("pattern", params)
end

---@param params SVGElement
---@return SVGElement
function SVG.Marker(params)
    return container_element("marker", params)
end

return SVG