
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

function lib.result_of_process(args, process_def)
    if not process_def.result_verbs then return args end
    local to = util.copy(args)
    for verb,verb_data in pairs(process_def.result_verbs) do
        to[verb] = verb_data
    end
    return to
end



function lib.add_item(args)
    if args.external then return end
    if sh.items_by_name[args.name] then return end

    print("Adding item:")
    print(serpent.block(args))

    args.stack_size = args.stack_size or 10
    sh.items[#sh.items+1] = args
    sh.items_by_name[args.name] = args

    if not args.group then args.group = args.name end

    if args.mill then
        lib.process("mill", {
            from = {{name = args.name, amount = 10}},
            to = lib.result_of_process({
                name = args.name.."-flour",
                amount = 40,
                tint = args.tint,
                stack_size = 100,
                group = args.mill.group or args.group,
            }, args.mill),
            time = 8,
        })
    end
    if args.slice then
        lib.process("prep", {
            from = {{name = args.name, amount = 1}},
            to = lib.result_of_process({
                name = args.name.."-sliced",
                amount = args.slice.amount,
                tint = args.tint,
                stack_size = args.stack_size * args.slice.amount,
                modifier = { type = "sliced", from = args },
                group = args.slice.group or args.group,
            }, args.slice),
            time = args.slice.time,
        })
    end
    if args.peel then
        lib.process("prep", {
            from = {{name = args.name, amount = 1}},
            to = lib.result_of_process({
                name = args.name.."-peeled",
                amount = 1,
                tint = args.tint,
                stack_size = args.stack_size,
                modifier = { type = "peeled", from = args },
                group = args.peel.group or args.group,
            }, args.peel),
            time = args.peel.time,
        })
    end
    if args.parboil then
        -- FIXME: boil
        lib.process("prep", {
            from = {{name = args.name, amount = args.parboil.batch_size}},
            to = lib.result_of_process({
                name = args.name.."-parboiled",
                amount = args.parboil.batch_size,
                tint = args.tint,
                stack_size = args.stack_size,
                modifier = { type = "parboiled", from = args },
                group = args.parboil.group or args.group,
            }, args.parboil),
            time = args.parboil.time,
        })
    end
end

function lib.process(verb, args)
    if args.group then args.to.group = args.group end
    lib.add_item(args.to)

    for _,from in pairs(args.from) do
        lib.add_item(from)
    end
    table.insert(sh[verb], args)
end

lib.dat = sh

return lib

