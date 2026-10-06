# LuaVG

**Ergonomic SVG generation with Lua.**

LuaVG is a lightweight Lua library for building SVG documents with ordinary Lua tables and function calls. Compose shapes and groups as nested elements, set SVG attributes directly, then serialize the result or save it to a file. It keeps SVG generation readable and programmable without making you assemble XML strings by hand.

## Installation

Install from LuaRocks:

```sh
luarocks install luavg
```

LuaVG requires Lua 5.1 or newer.

## Quick Start

```lua
require "luavg"

local drawing = SVG({
	width = 240,
	height = 140,
	viewBox = "0 0 240 140",

	Rect({
		x = 0,
		y = 0,
		width = 240,
		height = 140,
		fill = "#f4f1de",
	}),

	Circle({
		cx = 70,
		cy = 70,
		r = 38,
		fill = "#e07a5f",
	}),

	Text({
		x = 128,
		y = 78,
		fill = "#264653",
		font_size = 18,
	}, "Hello, SVG!"),
})

drawing:save("drawing.svg")
```

`require "luavg"` makes the library's constructors available as Lua globals. `SVG({...})` takes a table containing document attributes and child elements. Calling `:save(path)` writes the SVG document; `:toString()` returns its XML as a string.

## How It Works

- Pass SVG attributes as key-value pairs in a Lua table.
- Add child elements directly to the parent table, in the order they should appear.
- Nest elements to build groups, text, definitions, gradients, clipping paths, and other SVG structures.
- On regular SVG elements, attribute keys written in `snake_case` are emitted in SVG's `kebab-case`; for example, `stroke_width` becomes `stroke-width`.
- `SVG` defaults to the standard SVG namespace and a `200` by `200` canvas when `xmlns`, `width`, or `height` are omitted.

## Supported Elements

### Shapes and Paths

`Rect`, `Circle`, `Ellipse`, `Line`, `Polyline`, `Polygon`, and `Path` create the corresponding SVG shapes. `Polyline` and `Polygon` accept `points` either as an SVG coordinate string or as a list of `{ x = ..., y = ... }` points:

```lua
Polygon({
	points = {
		{ x = 20, y = 100 },
		{ x = 80, y = 20 },
		{ x = 140, y = 100 },
	},
	fill = "#81b29a",
})
```

### Text and Composition

`Text(params, text)` creates a text element with optional text content. Use `TSpan(params, text)` for styled or positioned spans inside text. `Group(params)` nests elements in a `<g>` element. `SVGElement(name, children)` provides a generic element constructor for SVG elements not covered by a named helper.

### Definitions and Resources

LuaVG also provides `Defs`, `Symbol`, `Use`, `Image`, `ForeignObject`, `Anchor`, `Title`, `Desc`, `Metadata`, `LinearGradient`, `RadialGradient`, `Stop`, `ClipPath`, `Mask`, `Pattern`, and `Marker`.

All constructors accept a table of attributes and, where applicable, nested child elements. `SVGElement:addChild(element)` appends a child and returns that element.

## Examples

The [`samples/showcase/showcase.lua`](samples/showcase/showcase.lua) file demonstrates shapes, text, gradients, patterns, clipping, masks, markers, symbols, and other helpers. Run it from the repository root to generate `samples/showcase/showcase.svg`:

```sh
lua samples/showcase/showcase.lua
```

The dice example in [`samples/dice/dices.lua`](samples/dice/dices.lua) builds six SVG dice faces.

## License

LuaVG is distributed under the MIT License. See [LICENSE](LICENSE).

