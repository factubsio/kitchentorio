
local f = require("food_funcs")

f.add_item{name = "tomato", tint = {1, 0, 0},
    stack_size = 4,
    tags = {"veg", "salad"},
    slice = { amount = 4, time = 2 },
    cost = 10,
}

f.add_item{name = "wheat", tint = {1, 1, 0},
    stack_size = 20,
    mill = {},
    tags = {"raw"},
    cost = 5,
}

f.add_item{name = "cheese", tint = {1, 1, 0.4},
    stack_size = 4,
    slice = { amount = 4, time = 4 },
    tags = {"salad"},
    cost = 50,
}

f.add_item{name = "bread", tint = {.71, .4, .11},
    stack_size = 4,
    slice = { amount = 10, time = 3},
    meal = { tier = 1, courses = {"main-side", "main"} },
}

f.add_item{name = "potato", tint = {1, 1, 1},
    stack_size = 10,
    peel = { time = 4,
        result_verbs =  { parboil = { time = 10, batch_size = 4 } },
    },
    slice = { amount = 4, time = 3,
    },
    tags = {"raw"},
    cost = 3,
}

f.add_item{name = "potato-roast", tint = {0.4, 0.4, 0.1},
    stack_size = 20,
    meal = { tier = 2, courses = {"main-side"} },
    group = "potato",
}


f.process("mix", {
    from = {
        {type = "fluid", name = "water", amount = 48, external = true},
        {name = "wheat-flour", amount = 24}
    },
    to = {name = "bread-dough-mixture", amount = 12},
    time = 40,
    group = "bread",
})

f.process("prep", {
    from = {
        {name = "bread-dough-mixture", amount = 9},
    },
    to = {name = "bread-dough", amount = 3},
    time = 100,
    group = "bread",
})

f.process("bake", {
    from = {{ name = "bread-dough", amount = 1}},
    to = {name = "bread", amount = 1},
    time = 200,
})

f.process("prep", {
    from = {
        {name = "bread-sliced", amount = 2},
        {name = "cheese-sliced", amount = 1},
        {name = "tomato-sliced", amount = 4},
    },
    to = { name = "sandwich-cheese-tomato", amount = 1, group = "sandwich"},
    time = 10,
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
    to = { name = "potato-roast@raw", amount = 20, tint = {0.85, 0.88, 0.2}, group = "potato" },
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
    to = { name = "sandwich-cheese-tomato", amount = 1},
    time = 10,
})

return f.dat
