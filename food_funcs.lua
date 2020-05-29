
local sh = {}
local lib = {}

local pre = "nkn-"
sh.pre = pre

sh.items = {}
sh.items_by_name = {}

sh.prep = {}
sh.mill = {}
sh.mix = {}
sh.bake = {}

local process_data = {
    ["mill"] = {
        station = "mill",
        suffix = "milled",
        from_amount = 40,
        to_amount = 100,
        time = 10,
    },

    ["slice"] = {
        station = "prep",
        suffix = "sliced",

        from_amount = 1,

    },
    ["peel"] = {
        station = "prep",
        suffix = "peeled",

        from_amount = 1,
        to_amount = 1,
    },

    -- FIXME: boil
    ["parboil"] = {
        station = "prep",
        suffix = "parboiled",

    },
}

-- function lib.result_of_process(args, process_def)
--
--     return to
-- end


function lib.add_item(item)
    if item.external then return end
    if sh.items_by_name[item.name] then return end

    print("Adding item:")
    print(serpent.block(item))

    item.stack_size = item.stack_size or 10
    sh.items[#sh.items+1] = item
    sh.items_by_name[item.name] = item

    local root_name,suffix = lib.root(item.name)

    if not item.group then item.group = root_name end

    local function auto_process(process_name)
        local process_item = item[process_name]
        if not process_item then return end

        local process_defaults = process_data[process_name]
        local function _v(key)
            return process_item[key] or process_defaults[key]
        end

        local to_amount = _v("to_amount")
        local from_amount = _v("from_amount")
        local from_to_factor = to_amount / from_amount

        local to_stack_size = math.floor(from_to_factor * item.stack_size)

        local to = {
            name = root_name .. '-' .. process_defaults.suffix .. suffix,
            amount = to_amount,
            tint = item.tint,
            stack_size = to_stack_size,
            group = process_item.group or item.group,
            order = item.order + 1,
            modifier = {type = process_defaults.suffix, from = item}
        }

        if process_item.result_verbs then
            for verb,verb_data in pairs(process_item.result_verbs) do
                to[verb] = verb_data
            end
        end

        lib.process(process_defaults.station, {
            from = {{name = item.name, amount = from_amount}},
            to = to,
            time = _v("time")
        })
    end

    auto_process("mill")
    auto_process("slice")
    auto_process("peel")
    auto_process("parboil")
    -- if item.slice then
    --     lib.process("prep", {
    --         from = {{name = item.name, amount = 1}},
    --         to = lib.result_of_process({
    --             name = root_name.."-sliced"..suffix,
    --             amount = item.slice.amount,
    --             tint = item.tint,
    --             stack_size = item.stack_size * item.slice.amount,
    --             modifier = { type = "sliced", from = item },
    --             group = item.slice.group or item.group,
    --         }, item.slice),
    --         time = item.slice.time,
    --     })
    -- end
    -- if item.peel then
    --     lib.process("prep", {
    --         from = {{name = item.name, amount = 1}},
    --         to = lib.result_of_process({
    --             name = root_name.."-peeled"..suffix,
    --             amount = 1,
    --             tint = item.tint,
    --             stack_size = item.stack_size,
    --             modifier = { type = "peeled", from = item },
    --             group = item.peel.group or item.group,
    --         }, item.peel),
    --         time = item.peel.time,
    --     })
    -- end
    -- if item.parboil then
    --     -- FIXME: boil
    --     lib.process("prep", {
    --         from = {{name = item.name, amount = item.parboil.batch_size}},
    --         to = lib.result_of_process({
    --             name = root_name.."-parboiled"..suffix,
    --             amount = item.parboil.batch_size,
    --             tint = item.tint,
    --             stack_size = item.stack_size,
    --             modifier = { type = "parboiled", from = item },
    --             group = item.parboil.group or item.group,
    --         }, item.parboil),
    --         time = item.parboil.time,
    --     })
    -- end
end

function lib.process(verb, args)
    if args.group then args.to.group = args.group end
    lib.add_item(args.to)

    for _,from in pairs(args.from) do
        lib.add_item(from)
    end
    table.insert(sh[verb], args)
end

function lib.root(name)
    local index = string.find(name, "@", 0, true)
    if not index then return name,'' end
    return string.sub(name, 1, index-1), string.sub(name, index)
end

lib.dat = sh

-- Hmm
lib.dat.root = lib.root

return lib

