local SVG = require 'luavg'
local width, height = 200, 200
local padding = 10
local stroke_color = "black"
local dot_border_distance = padding * 5

local function dice_frame()
    return SVG.Rect({
        x = padding,
        y = padding,
        width = width - padding * 2,
        height = height - padding * 2,
        rx = 10,
        ry = 10,
        fill = "none",
        stroke = stroke_color,
        stroke_width = ("%dpx"):format(padding),
    })
end

SVG.Document({
    width = width,
    height = height,

    dice_frame(),

    SVG.Circle({
        r = padding,
        cx = width / 2,
        cy = height / 2,
    }),
}):save("samples/dice/dice_1.svg")


SVG.Document({
    width = width,
    height = height,

    dice_frame(),

    SVG.Circle({
        r = padding,
        cx = dot_border_distance,
        cy = height - dot_border_distance,
    }),

    SVG.Circle({
        r = padding,
        cx = width - dot_border_distance,
        cy = dot_border_distance,
    }),
}):save("samples/dice/dice_2.svg")

SVG.Document({
    width = width,
    height = height,

    dice_frame(),

    SVG.Circle({
        r = padding,
        cx = width / 2,
        cy = height / 2,
    }),

    SVG.Circle({
        r = padding,
        cx = dot_border_distance,
        cy = height - dot_border_distance,
    }),

    SVG.Circle({
        r = padding,
        cx = width - dot_border_distance,
        cy = dot_border_distance,
    }),
}):save("samples/dice/dice_3.svg")

SVG.Document({
    width = width,
    height = height,

    dice_frame(),


    SVG.Circle({
        r = padding,
        cx = dot_border_distance,
        cy = dot_border_distance,
    }),

    SVG.Circle({
        r = padding,
        cx = width - dot_border_distance,
        cy = dot_border_distance,
    }),

    SVG.Circle({
        r = padding,
        cx = width - dot_border_distance,
        cy = height - dot_border_distance,
    }),

    SVG.Circle({
        r = padding,
        cx = dot_border_distance,
        cy = height - dot_border_distance,
    }),
}):save("samples/dice/dice_4.svg")

SVG.Document({
    width = width,
    height = height,

    dice_frame(),

    {

        SVG.Circle({
            r = padding,
            cx = width / 2,
            cy = height / 2,
        }),

        SVG.Circle({
            r = padding,
            cx = dot_border_distance,
            cy = dot_border_distance,
        }),

        SVG.Circle({
            r = padding,
            cx = width - dot_border_distance,
            cy = dot_border_distance,
        }),

        SVG.Circle({
            r = padding,
            cx = width - dot_border_distance,
            cy = height - dot_border_distance,
        }),

        SVG.Circle({
            r = padding,
            cx = dot_border_distance,
            cy = height - dot_border_distance,
        }),
    }
}):save("samples/dice/dice_5.svg")

SVG.Document({
    width = width,
    height = height,

    dice_frame(),


    SVG.Circle({
        r = padding,
        cx = dot_border_distance,
        cy = dot_border_distance,
    }),

    SVG.Circle({
        r = padding,
        cx = width - dot_border_distance,
        cy = dot_border_distance,
    }),

    SVG.Circle({
        r = padding,
        cx = width - dot_border_distance,
        cy = height - dot_border_distance,
    }),

    SVG.Circle({
        r = padding,
        cx = dot_border_distance,
        cy = height - dot_border_distance,
    }),

    SVG.Circle({
        r = padding,
        cx = dot_border_distance,
        cy = height / 2,
    }),

    SVG.Circle({
        r = padding,
        cx = width - dot_border_distance,
        cy = height / 2,
    }),
}):save("samples/dice/dice_6.svg")
