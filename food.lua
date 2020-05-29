
local f = require("food_funcs")

local roast_color = util.color("966b15")
local raw_color = util.color("f2bc8d")
local function roast(name, args)
    -- FIXME ROAST NOT BAKE?
    f.process("bake", {
        from = {{ name = name.."@raw", amount = args.amount }},
        to = { name = name, amount = args.amount, tint = roast_color, order = args.order },
        time = args.time,
    })
end

f.add_item{name = "vegetable-oil",
    stack_size = 10,
    cost = 50,
    order = 1,
}

f.add_item{name = "milk-coconut",
    stack_size = 10,
    cost = 50,
    order = 1,
    group = "milk"
}

f.add_item{name = "spices",
    stack_size = 100,
    cost = 150,
    order = 1,
}

f.add_item{name = "cashews",
    stack_size = 100,
    cost = 80,
    order = 1,
}

f.add_item{
    name = "shitake", tint = {0.4, 0.1, 0.1},
    stack_size = 10,
    slice = { to_amount = 4, time = 2},
    cost = 30,
    group = "veg",
    order = 1,
}
f.add_item{
    name = "mushroom", tint = {0.9, 0.9, 0.9},
    stack_size = 10,
    slice = { to_amount = 4, time = 2},
    cost = 10,
    group = "veg",
    order = 1,
}

f.add_item{
    name = "onion", tint = {0.9, 0.9, 0.6},
    stack_size = 10,
    slice = { to_amount = 6, time = 3},
    cost = 10,
    group = "veg",
    order = 1,
}

f.add_item{
    name = "garlic", tint = {0.9, 0.9, 0.8},
    stack_size = 10,
    -- Should this be mince???
    slice = { to_amount = 4, time = 6},
    cost = 10,
    group = "veg",
    order = 1,
}

f.add_item{
    name = "chicken-raw", tint = raw_color,
    stack_size = 2,
    cost = 50,
    order = 1,
    group = "chicken",
}



f.add_item{name = "rice@white", tint = {1, 1, 1},
    stack_size = 100,
    mill = {},
    cost = 5,
    order = 1,
}

f.add_item{name = "rice@brown", tint = util.color("d1bc86"),
    stack_size = 100,
    mill = {},
    cost = 5,
    order = 1,
}


f.add_item{name = "tomato", tint = {1, 0, 0},
    stack_size = 4,
    tags = {"veg", "salad"},
    slice = { to_amount = 4, time = 2 },
    cost = 10,
    group = "veg",
    order = 1,
}

f.add_item{name = "wheat", tint = {1, 1, 0},
    stack_size = 20,
    mill = {},
    tags = {"raw"},
    cost = 5,
    order = 1,
}

f.add_item{name = "cheese", tint = {1, 1, 0.4},
    stack_size = 4,
    slice = { to_amount = 4, time = 4 },
    tags = {"salad"},
    cost = 50,
    order = 1,
}

f.add_item{name = "bread", tint = {.71, .4, .11},
    stack_size = 4,
    slice = { to_amount = 10, time = 3},
    meal = { tier = 1, courses = {"main-side", "main"} },

    order = 50,
}

f.add_item{name = "potato", tint = {1, 1, 1},
    stack_size = 10,
    peel = { time = 4,
        result_verbs =  {
            parboil = { time = 10, from_amount = 4, to_amount = 4 }
        },
    },
    slice = { to_amount = 4, time = 3, },
    tags = {"raw"},
    cost = 3,
    order = 1,
}


f.add_item{name = "potato-roast", tint = roast_color,
    stack_size = 20,
    meal = { tier = 2, courses = {"main-side"} },
    group = "potato",

    order = 80,
}

f.add_item{name = "curry@THAI_COCONUT_CHICKEN", tint = {.8, .9, .9},
    stack_size = 1,
    meal = { tier = 4, courses = {"main"} },
    group = "curry",
    order = 90,
}


f.process("mix", {
    from = {
        {type = "fluid", name = "water", amount = 48, external = true},
        {name = "wheat-milled", amount = 24}
    },
    to = {name = "bread-dough-mixture", amount = 12, order = 3 },
    time = 40,
    group = "bread",
})

f.process("prep", {
    from = {
        {name = "bread-dough-mixture", amount = 9},
    },
    to = {name = "bread-dough", amount = 3, order = 4},
    time = 100,
    group = "bread",
})

f.process("bake", {
    from = {{ name = "bread-dough", amount = 1}},
    to = {name = "bread", amount = 1},
    time = 200,
})

-- process("bake", {
--     from = {{ name = "potato-peeled", amount = 20}},
--     to = {name = "potato-parboiled", amount = 20},
--     time = 15,
-- })


f.process("prep", {
    from = {
      { name = "potato-peeled-parboiled", amount = 20 },
      { name = "vegetable-oil", amount = 1 },
    },
    to = {
        name = "potato-roast@raw", amount = 20, tint = {0.85, 0.88, 0.2}, group = "potato", order = 10,
        roast = { time = 100},
    },
    time = 1,
})

roast("potato-roast", {order = 20, amount = 20, time = 100})


f.process("prep", {
    from = {
        {name = "bread-sliced", amount = 2},
        {name = "cheese-sliced", amount = 1},
        {name = "tomato-sliced", amount = 4},
    },
    to = { name = "sandwich-cheese-tomato", amount = 1, order = 80},
    time = 10,
})

f.process("prep", {
    icon = "cut-chicken",
    group = "chicken",
    order = 2,
    from = {
        {name = "chicken-raw", amount = 2},
    },
    multi_to = {
        {
            name = "chicken-drumstick@raw",  amount = 2, order = 3,
            tint = raw_color,
        },
        {
            name = "chicken-wing@raw",  amount = 2, order = 3,
            tint = raw_color,
        },
        {
            name = "chicken-breast@raw",  amount = 2, order = 3,
            tint = raw_color,
            slice = { to_amount = 8, time = 2},
        },
    },
    time = 10,
})

roast("chicken-drumstick", {
    amount = 2, order = 5, time = 20,
})

roast("chicken-wing", {
    amount = 2, order = 5, time = 20,
})
roast("chicken-breast", {
    amount = 2, order = 5, time = 20,
})





f.process("hob", {
    from = {
        {name = "milk-coconut", amount = 1},
        {name = "spices", amount = 10},
        {name = "cashews", amount = 20},
        {name = "vegetable-oil", amount = 2},
        -- {name = "water", amount = 20},
    },
    to = { name = "sauce@coconut+cachew-curry", amount = 50, order = 10 },
    time = 20,
})

f.process("hob", {
    from = {
        {name = "sauce@coconut+cachew-curry", amount = 25},
        {name = "chicken-breast-sliced@raw", amount = 12},
        {name = "garlic-sliced", amount = 2},
        {name = "onion-sliced", amount = 4},
        {name = "shitake-sliced", amount = 8},
    },
    to = { name = "curry@THAI_COCONUT_CHICKEN", amount = 1 },
    time = 20,
})



return f.dat
