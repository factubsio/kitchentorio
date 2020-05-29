// reqs
local food = require("food")

local pre = food.pre

local function pad10(num)
    if num < 10 then
        return "0" .. tostring(num)
    else
        return tostring(num)
    end
end


local function icon(raw_file)
    local file = food.root(raw_file)
    if file == "mill" then
        assert(false)
    end
    return "__kitchentorio__/icons/" .. file .. ".png"
end
local function sprite(file)
    return "__kitchentorio__/sprites/" .. file .. ".png"
end

local blank = {
    filename = sprite("blank_16x16"),
    size = 16,
}

local function mkbox(w, h, inset)
    inset = (inset and (inset/2)) or 0
    return {{-w/2 + inset, -h/2 + inset}, {w/2 - inset, h/2 - inset}}
end


local function mkicon(name, rgb)
    return {
        {
            icon = icon(name),
            icon_size = 192,
            tint = rgb and rgb or {1, 1, 1}
        }
    }
end

local unique_modified_icons = {
    milled = true,
}

local function mkicon_with_badges(raw, name, chain, rgb)
    local icons = {{
            icon = icon(name),
            icon_size = 192,
            tint = rgb and rgb or {1, 1, 1}
    }}

    local offsets = {{8, 8}, {8, -8}}
    local offset_index = 0
    for _,entry in ipairs(chain) do
        if unique_modified_icons[entry] then
            icons[1].icon = icon(raw)
        else
            icons[#icons+1] = {
                icon = icon(entry),
                icon_size = 96,
                scale = 0.15,
                shift = offsets[#chain - offset_index],
            }
            offset_index = offset_index + 1
        end
    end

    return icons
end


data:extend{
    { type = "recipe-category", name = pre.."milling", },
    { type = "recipe-category", name = pre.."mixing", },
    { type = "recipe-category", name = pre.."prep", },
    { type = "recipe-category", name = pre.."baking", },
    { type = "recipe-category", name = pre.."hob", },
}

data:extend{
    {
        name = pre.."milling-machine",
        type = "assembling-machine",
        crafting_categories = {pre.."milling"},
        crafting_speed = 1,
        energy_source = {type = "void"},
        energy_usage = "100KW",

        animation =  {
            frame_count = 64,
            line_length = 8,
            filename = sprite("mill_base"),
            size = 256,
            scale = .5,
        },

        collision_box = mkbox(3, 3, 0.2),
        selection_box = mkbox(3, 3),

        placed_by = pre.."milling-machine",
        minable = { mining_time = 1, result = pre.."milling-machine" },
    },
    {
        type = "item",
        name = pre.."milling-machine",
        stack_size = 5,
        icons = mkicon("windmill"),
        place_result = pre.."milling-machine"
    }
}

data:extend{
    {
        name = pre.."prep",
        type = "assembling-machine",
        crafting_categories = {pre.."prep"},
        crafting_speed = 1,
        energy_source = {type = "void"},
        energy_usage = "100KW",

        animation =  {
            frame_count = 225,
            stripes = {
                {width_in_frames = 8, height_in_frames = 8, filename = sprite("prep_base") },
                {width_in_frames = 8, height_in_frames = 8, filename = sprite("prep_base2") },
                {width_in_frames = 8, height_in_frames = 8, filename = sprite("prep_base3") },
                {width_in_frames = 8, height_in_frames = 5, filename = sprite("prep_base4") },
            },
            size = 256,
            scale = .5,
        },

        collision_box = mkbox(3, 3, 0.2),
        selection_box = mkbox(3, 3),

        placed_by = pre.."prep",
        minable = { mining_time = 1, result = pre.."prep" },
    },
    {
        type = "item",
        name = pre.."prep",
        stack_size = 5,
        icons = mkicon("table"),
        place_result = pre.."prep"
    }
}

data:extend{
    {
        name = pre.."mixer",
        type = "assembling-machine",
        crafting_categories = {pre.."mixing"},
        crafting_speed = 1,
        energy_source = {type = "void"},
        energy_usage = "100KW",

        animation =  {
            line_length = 8,
            frame_count = 64,
            filename = sprite("mixer_base"),
            size = 256,
            scale = .5,
        },

        fluid_boxes = {
            {
                pipe_covers = pipecoverspictures(),
                pipe_picture = assembler3pipepictures(),
                pipe_connections = { { type = "input", position = {0, -1.75} } },
                production_type = "input",
                render_layer = "lower-object-above-shadow",
            }
        },

        collision_box = mkbox(3, 3, 0.2),
        selection_box = mkbox(3, 3),

        placed_by = pre.."mixer",
        minable = { mining_time = 1, result = pre.."mixer" },
    },
    {
        type = "item",
        name = pre.."mixer",
        stack_size = 5,
        icons = mkicon("whisk"),
        place_result = pre.."mixer"
    }
}


data:extend{
    {
        name = pre.."hob",
        type = "assembling-machine",
        crafting_categories = {pre.."hob"},
        crafting_speed = 1,
        energy_source = {type = "void"},
        energy_usage = "100KW",

        animation =  {
            line_length = 8,
            frame_count = 64,
            -- FIXME: FIXME FIMXE
            filename = sprite("mixer_base"),
            size = 256,
            scale = .5,
        },

        fluid_boxes = {
            {
                pipe_covers = pipecoverspictures(),
                pipe_picture = assembler3pipepictures(),
                pipe_connections = { { type = "input", position = {0, -1.75} } },
                production_type = "input",
                render_layer = "lower-object-above-shadow",
            }
        },

        collision_box = mkbox(3, 3, 0.2),
        selection_box = mkbox(3, 3),

        placed_by = pre.."hob",
        minable = { mining_time = 1, result = pre.."hob" },
    },
    {
        type = "item",
        name = pre.."hob",
        stack_size = 5,
        icons = mkicon("hob"),
        place_result = pre.."hob"
    }
}

data:extend{
    {
        name = pre.."baking-oven",
        type = "assembling-machine",
        crafting_categories = {pre.."baking"},
        crafting_speed = 1,
        energy_source = {type = "void"},
        energy_usage = "100KW",

        animation =  {
            line_length = 8,
            frame_count = 64,
            filename = sprite("oven_base"),
            size = 256,
            scale = .5,
        },

        collision_box = mkbox(3, 3, 0.2),
        selection_box = mkbox(3, 3),

        placed_by = pre.."baking-oven",
        minable = { mining_time = 1, result = pre.."baking-oven" },

        -- icons = mkicon("furnace"),
    },
    {
        type = "item",
        name = pre.."baking-oven",
        stack_size = 5,
        icons = mkicon("furnace"),
        place_result = pre.."baking-oven"
    }
}

function map(tbl, f)
    local t = {}
    for index,v in ipairs(tbl) do
        t[index] = f(v)
    end
    return t
end

function fix(spec)
    if spec.external then
        return spec
    else
        return {name = pre .. spec.name, amount = spec.amount, type = spec.type}
    end

end

function recipe(type, rec)
    local name = nil
    local proto = {
        type = "recipe",
        name = name,
        category = pre..type,
        energy_required = rec.time,

        ingredients = map(rec.from, fix),
    }

    if rec.multi_to then
        name = ''
        for _,to in ipairs(rec.multi_to) do
            name = name.."+"..to.name
        end
        proto.results = map(rec.multi_to, fix)
        proto.icons = mkicon(rec.icon)
        proto.subgroup = pre..rec.group
    else
        name = pre..type..rec.to.name
        proto.results = { fix(rec.to) }
    end

    name = name .. '__from__'
    for _,from in ipairs(rec.from) do
        name = name.."+"..from.name
    end


    proto.name = name
    return proto

end

data:extend{
    {
        type = "item-group",
        name = pre.."food",
        icons = mkicon("meta-group"),
    }
}

local subgroups_seen = {}

local function make_subgroup(name)
    if subgroups_seen[name] then return end
    subgroups_seen[name] = true
    data:extend{{
        type = "item-subgroup",
        name = pre..name,
        group = pre.."food",
    }}
end

for _,item in pairs(food.items) do
    make_subgroup(item.group)
    local proto =
    {
        type = "tool",
        name = pre..item.name,
        stack_size = item.stack_size,
        icons = mkicon(item.name, item.tint),
        order = pad10(item.order),
        subgroup = pre..item.group,
        durability = 100000,
    }
    local mod = item.modifier
    if mod then
        local mod_chain = {}
        local from = nil
        while mod do
            mod_chain[#mod_chain+1] = mod.type
            from = mod.from.name

            mod = mod.from.modifier
        end
        proto.icons = mkicon_with_badges(item.name, from, mod_chain, item.tint)
    end
    data:extend{proto}
end

for _,recipe_spec in pairs(food.mill) do
    data:extend{recipe("milling", recipe_spec)}
end

for _,recipe_spec in pairs(food.mix) do
    data:extend{recipe("mixing", recipe_spec)}
end

for _,recipe_spec in pairs(food.prep) do
    data:extend{recipe("prep", recipe_spec)}
end

for _,recipe_spec in pairs(food.bake) do
    data:extend{recipe("baking", recipe_spec)}
end

for _,recipe_spec in pairs(food.hob) do
    data:extend{recipe("hob", recipe_spec)}
end

local delivery_chest = {
    name = pre.."delivery-chest",
    type = "container",
    inventory_size = 128,
    picture = {
        layers = {
            {
                filename = "__base__/graphics/entity/logistic-chest/hr-logistic-chest-passive-provider.png",
                width = 66,
                height = 74,
            },
            {
                filename = "__base__/graphics/entity/logistic-chest/hr-logistic-chest-shadow.png",
                width = 96,
                height = 44,
                draw_as_shadow = true,
                shift = { 0.265625, 0.15625 },
            },
        }
    },
    collision_box = mkbox(2, 2, .2),
    selection_box = mkbox(2, 2),
}
-- delivery_chest.picture.scale = 2
local order_chest = {
    name = pre.."order-chest",
    type = "container",
    inventory_size = 8,
    picture = {
        filename = "__base__/graphics/entity/logistic-chest/hr-logistic-chest-requester.png",
        width = 66,
        height = 74,
    },
    collision_box = mkbox(2, 2, .2),
    selection_box = mkbox(2, 2),
}

data:extend{order_chest, delivery_chest}

data:extend{{
    type = "sprite",
    name = pre.."stopwatch",
    size = 192,
    filename = icon("stopwatch"),
}}

local function stripe(w, h, count, name)
    local stripes = {}
    for i=1,count do
        stripes[#stripes+1] = { width_in_frames = w, height_in_frames = h, filename = sprite(name..tostring(i)) }
    end
    return stripes
end

data:extend{{
    type = "animation",
    name = pre.."delivery-zone",
    frame_count = 247,
    stripes = stripe(5, 5, 10, "delivery_zone"),
    size = 384,
    -- scale = .5,
}}
data:extend{{
    type = "sprite",
    name = pre.."left-wall-shadow",
    size = 384,
    filename = sprite("left_wall_shadow"),
}}


data:extend{{
    type = "market",
    name = pre.."market",
    picture = {
        filename = sprite("market"),
        width = 256,
        height = 256,
    },
    collision_box = mkbox(8, 6, .2),
    selection_box = mkbox(8, 6),
}}

data:extend{{
    type = "item",
    name = pre.."coin",
    stack_size = 1000000,
    icons = mkicon("crown-coin"),
}}

data:extend{{
    type = "electric-pole",
    name = pre.."substation",
    pictures = {
        direction_count = 1,
        filename = blank.filename,
        size = blank.size,
    },
    supply_area_distance = 64,
    maximum_wire_distance = 64,
    connection_points = {
        {wire = {}, shadow = {}}
    },
}}

for hour=1,12 do
    local am = {
        type = "sprite",
        name = pre.."clock-"..hour .. "-am",
        layers = {
            {
                size = 384,
                filename = icon("clock/outer00"..pad10(hour)),
            },
            {
                size = 384,
                filename = icon("clock/inner0002")
            },
        }
    }
    local pm = util.copy(am)
    pm.layers[2].filename = icon("clock/inner0001")
    pm.name = pre.."clock-"..hour.."-pm"
    data:extend{pm, am}
end

print("HERE")