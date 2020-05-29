
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
sh.hob = {}

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
    -- ["mince"] = {
    --     station = "prep",
    --     suffix = "minced",

    --     from_amount = 1,
    -- },
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
    local existing = sh.items_by_name[item.name]

    -- FIXME: should we append new data and/or validate the incoming data is the same as existing?
    if existing then return existing end

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

    return item
end


function lib.process(verb, args)
    local first_nkn_item = nil
    -- Handle these first to ensure "group" gets propogated forwards
    for _,from in pairs(args.from) do
        local added = lib.add_item(from)
        if added and first_nkn_item == nil then
            first_nkn_item = added
        end
    end

    local function propogate_group_forward(to)
        if args.group then
            to.group = args.group
        elseif first_nkn_item and first_nkn_item.group then
            to.group = first_nkn_item.group
        end
    end

    if args.multi_to then
        for _,to in pairs(args.multi_to) do
            propogate_group_forward(to)
            lib.add_item(to)
        end
    else
        propogate_group_forward(args.to)
        lib.add_item(args.to)
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

