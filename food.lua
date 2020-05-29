
local f = require("food_funcs")


f.add_item{name = "vegetable-oil",
    stack_size = 10,
    cost = 50,
    order = 1,
}


f.add_item{name = "rice@white", tint = {1, 1, 1},
    stack_size = 100,
    mill = {},
    cost = 5,
    order = 1,
}

f.add_item{name = "rice@brown", tint = {1, .7, .5},
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

f.add_item{name = "potato-roast", tint = {0.4, 0.4, 0.1},
    stack_size = 20,
    meal = { tier = 2, courses = {"main-side"} },
    group = "potato",

    order = 80,
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
    to = { name = "potato-roast@raw", amount = 20, tint = {0.85, 0.88, 0.2}, group = "potato", order = 10 },
    time = 1,
})

f.process("bake", {
    from = {{ name = "potato-roast@raw", amount = 20 }},
    to = { name = "potato-roast", amount = 20 },
    time = 100,
})

f.process("prep", {
    from = {
        {name = "bread-sliced", amount = 2},
        {name = "cheese-sliced", amount = 1},
        {name = "tomato-sliced", amount = 4},
    },
    to = { name = "sandwich-cheese-tomato", amount = 1, order = 80},
    time = 10,
})

return f.dat
