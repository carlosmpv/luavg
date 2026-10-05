---Creates a new SVG Element
---@param name any
---@param childs SVGElement
---@return SVGElement
function SVGElement(name, childs)
    childs = childs or {}
    ---@class SVGElement : Element
    ---@field [number] SVGElement
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

-- [Exposed=Window]
-- interface SVGCircleElement : SVGGeometryElement {
--   [SameObject] readonly attribute SVGAnimatedLength cx;
--   [SameObject] readonly attribute SVGAnimatedLength cy;
--   [SameObject] readonly attribute SVGAnimatedLength r;
-- };
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

-- [Exposed=Window]
-- interface SVGEllipseElement : SVGGeometryElement {
--   [SameObject] readonly attribute SVGAnimatedLength cx;
--   [SameObject] readonly attribute SVGAnimatedLength cy;
--   [SameObject] readonly attribute SVGAnimatedLength rx;
--   [SameObject] readonly attribute SVGAnimatedLength ry;
-- };


-- [Exposed=Window]
-- interface SVGLineElement : SVGGeometryElement {
--   [SameObject] readonly attribute SVGAnimatedLength x1;
--   [SameObject] readonly attribute SVGAnimatedLength y1;
--   [SameObject] readonly attribute SVGAnimatedLength x2;
--   [SameObject] readonly attribute SVGAnimatedLength y2;
-- };
