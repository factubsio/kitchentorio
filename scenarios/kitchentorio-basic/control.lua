if __DebugAdapter then __DebugAdapter.levelPath("kitchentorio","scenarios/kitchentorio-basic/") end

local util = require("util")
local handler = require("event_handler")

local lib = {}
local dat = nil
local food = require("__kitchentorio__/food")


local funcs = {}

local function get_frame(tick, anim_def)
    return math.floor((tick * anim_def.speed) % anim_def.frames)
end

local function set_frame(tick, frame, anim_def, anim)
    rendering.set_animation_speed(anim, anim_def.speed)
    if anim_def.speed == 0 then
      rendering.set_animation_offset(anim, frame)
    else
      local current_frame = get_frame(tick, anim_def)
      rendering.set_animation_offset(anim, frame - current_frame)
    end
end

local delivery_anim = {speed = 1, frames = 247}
local delivery_anim_stopped = {speed = 0, frames = 247}

local function interp(s, tab, secondary_tab)
    secondary_tab = secondary_tab or {}
    return (s:gsub('($%b{})', function(w)
        local key = w:sub(3, -2)
        return tab[key] or secondary_tab[key] or w end
    ))
end

local actions = { }

local function sell(args)
    dat.offers[#dat.offers+1] = args
    dat.market.add_market_item{
        price = {{"nkn-coin", args.price}},
        offer = {type = "give-item", item = args.item, count = 1},
    }
end

local function on_sold(event)
    -- Fixme: multiple markets?
    local offer = dat.offers[event.offer_index]

    local player = game.get_player(event.player_index)
    local queue = dat.incoming.express.bought

    player.remove_item{name = offer.item, count = event.count}

    queue[#queue+1] = {name = offer.item, count = event.count * offer.count}
    local kitchen = event.market.surface
    kitchen.create_entity{name = "flying-text", position = event.market.position, text = "Delivery queued"}

    dat.time_of_last_purchase = game.ticks_played
    funcs.refresh_delivery_gui()
end

local slots = {}
function slots.set_state(slot, state)
    if slot and slot.state == state then return end

    if state == "idle" then
        dat.idle_order_slots[#dat.idle_order_slots + 1] = slot.index
        table.sort(dat.idle_order_slots)
        rendering.set_visible(slot.active_indicator, false)
        slot.order = nil
    else
        if slot == nil then
            local slot_index = dat.idle_order_slots[#dat.idle_order_slots]
            slot = dat.order_slots[slot_index]
            dat.idle_order_slots[slot.index] = nil
        end

        rendering.set_visible(slot.active_indicator, true)
    end

    slot.state = state

    return slot
end

local function check_order_status(slice)
    local slot = dat.order_slots[slice]
    if slot.state ~= "idle" then
        local order = slot.order

        -- Check to see if time ran out
        if slot.deadline <= game.ticks_played then
            game.print(interp("Order [slot:${index}] not delivered on time!", slot))
            dat.today.orders_bad[#dat.today.orders_bad+1] = order
            slots.set_state(slot, "idle")
            return
        end

        -- Check to see if the order is fulfilled
        local inv = slot.chest.get_output_inventory()
        local contents = inv.get_contents()

        local good = true

        for _,item in pairs(order) do
            local curr = contents[item.name]
            if not curr or curr < item.count then
                good = false
            end
        end

        if good then
            game.print(interp("Order [slot:${index}] delivered: SUCCESS!", slot))
            dat.today.orders_good[#dat.today.orders_good+1] = order
            for _,item in pairs(order) do
                inv.remove(item)
            end
            slots.set_state(slot, "idle")
        end
    end
end

local function schedule(when, who, what)
    local args = {who = who, what = what}

    local on_that_tick = dat.schedule[when]
    if on_that_tick then
        on_that_tick[#on_that_tick+1] = args
    else
        dat.schedule[when] = {args}
    end
end

-- 20 seconds, should be WAAAAY bigger
local min_time_between_deliveries = 1000
local delivery_time = 600

local min_time_between_orders = 500
local min_delivery_time = 100000
local max_delivery_time = min_delivery_time + 1000000

local function eta(when, tick)
    local rough_time = math.floor((when - tick) / 60)
    if rough_time < 4 then
        return "very soon!"
    else
        return "in about " .. tostring(rough_time) .. " seconds"
    end

end

function funcs.refresh_order_stats_gui()

    local total_str = tostring(#dat.today.orders_total)
    local good_str = tostring(#dat.today.orders_good)
    local bad_str = tostring(#dat.today.orders_bad)

    for _,player in pairs(game.connected_players) do
        local root = player.gui.goal.stats["_"]
        root.nkn_total.nkn_value.caption = total_str
        root.nkn_good.nkn_value.caption = good_str
        root.nkn_bad.nkn_value.caption = bad_str
    end

end

local function sec2tick(time)
    return time * 60
end

local function min2tick(time)
    return time * 60 * 60
end

local hours_per_day = 24
local mins_per_hour = 60

local ticks_per_day = min2tick(5)
local ticks_per_hour = math.floor(ticks_per_day / hours_per_day)
local ticks_per_min = math.floor(ticks_per_day / (hours_per_day * mins_per_hour))

local function pad10(num)
    if num < 10 then
        return "0" .. tostring(num)
    else
        return tostring(num)
    end
end

function funcs.refresh_clock()
    local kitchen = game.get_surface(1)
    local tick = game.ticks_played

    local day = tick / ticks_per_day
    local tick_in_day = tick % ticks_per_day

    local min = math.floor(tick_in_day / ticks_per_min)
    local hour = math.floor(min / mins_per_hour)
    local min_in_hour = min % mins_per_hour

    local roughmin = math.floor(min_in_hour / 5) * 5

    local clock_str = pad10(hour) .. ":" .. pad10(roughmin)


    local hour12 = hour % 12
    local ampm = "am"

    if hour > 12 then ampm = "pm" end
    if hour12 == 0 then hour12 = 12 end

    for _,player in pairs(game.connected_players) do
        local root = player.gui.goal.nkn_clock["_"]

        if root.nkn_clock_text then
            root.nkn_clock_text.caption = clock_str
        end

        if root.nkn_clock then
            root.nkn_clock.sprite = "nkn-clock-" .. tostring(hour12) .. "-" .. ampm
        end
    end
end

function funcs.refresh_delivery_gui()
    local status = nil
    local tick = game.ticks_played

    local queue = dat.incoming.express

    local num_on_the_way = #queue.on_the_way
    local num_bought = #queue.bought

    if num_on_the_way > 0 then
        status = tostring(num_on_the_way) .. " items arriving " .. eta(queue.expected, tick)
    else
        status = "n/a"
    end
    for _,player in pairs(game.connected_players) do
        local root = player.gui.goal.incoming["_"]
        root.delivery_status.nkn_value.caption = status
    end

    if num_bought > 0 then
        local time_since_last_delivery = tick - queue.time_of_last_delivery
        if num_on_the_way > 0 then
            status = tostring(num_bought) .. " items waiting for previous delivery to complete"
        elseif time_since_last_delivery < min_time_between_deliveries then
            status = tostring(num_bought) .. " items dispatching " .. eta(queue.time_of_last_delivery + min_time_between_deliveries, tick)
        else
            status = "dispatching!"
        end
    else
        status = "n/a"
    end
    for _,player in pairs(game.connected_players) do
        local root = player.gui.goal.incoming["_"]
        root.dispatch_status.nkn_value.caption = status
    end

end

local function start_delivery()
    local tick = game.ticks_played
    local queue = dat.incoming.express

    if #queue.bought == 0 then return end

    if next(queue.on_the_way) then return end

    local time_since_last_delivery = tick - queue.time_of_last_delivery
    if time_since_last_delivery < min_time_between_deliveries then return end

    local time_since_last_purchase = tick - dat.time_of_last_purchase
    if time_since_last_purchase < 120 then return end

    queue.on_the_way = queue.bought
    queue.bought = {}
    queue.expected = tick + delivery_time
end

local function deliver_items()
    local tick = game.ticks_played

    local queue = dat.incoming.express
    if queue.expected and game.ticks_played >= queue.expected  then
        set_frame(game.tick, 0, delivery_anim, dat.delivery_zone)
        schedule(tick + delivery_anim.frames, "set-frame", {def = delivery_anim_stopped, handle = dat.delivery_zone})
        local insert = dat.delivery_chest.insert
        for _,order in pairs(queue.on_the_way) do
            insert(order)
        end

        queue.time_of_last_delivery = tick
        queue.expected = nil
        queue.on_the_way = {}
    end
end

local function create_order()
    local since_last_order = game.ticks_played - dat.last_order_received
    if since_last_order < min_time_between_orders then return end

    -- Chance of receiving a new order is `idle_slots in total_slosts`
    if math.random(#dat.order_slots) > #dat.idle_order_slots then
        -- local percent = 100 * #dat.idle_order_slots / #dat.order_slots
        -- game.print("did not receive new order (" .. percent .. "% chance)")
        return
    end

    dat.last_order_received = game.ticks_played

    if #dat.idle_order_slots == 0 then
        return
    end

    local time_to_deliver = math.random(min_delivery_time, max_delivery_time)

    local slot = slots.set_state(nil, "active")
    slot.received = game.ticks_played
    slot.deadline = game.ticks_played + time_to_deliver

    local control = slot.combinator.get_or_create_control_behavior()

    local order = {
        {name = "nkn-bread", count = 2 }
    }
    slot.order = order

    local order_string = ""
    local params = { }

    for index,item in pairs(order) do
        params[#params+1] = { index = index, signal = { type = "item", name = item.name}, count = item.count}

        if index > 1 then order_string = order_string .. ", " end

        order_string = order_string .. tostring(item.count) .. "x " .. item.name
    end

    dat.today.orders_total[#dat.today.orders_total + 1] = order
    control.parameters = { parameters = params }

    -- game.print(interp(
    --     "Order [slot:${index}] [items:${order_string}] received on ${received}, deadline is: ${deadline}",
    --     slot, {order_string = order_string}
    -- ))

end


local function setup_actions()
    for i=1,#dat.order_slots do
        actions[i] = check_order_status
    end

    local next_slice = #dat.order_slots + 1

    local function act(fun)
        print('act: ' .. tostring(fun) .. ' @ offset: ' .. tostring(next_slice))
        actions[next_slice] = fun
        next_slice = next_slice + 1
    end

    act(create_order)
    act(start_delivery)
    act(deliver_items)


    -- Probably best to update gui at the end
    act(funcs.refresh_clock)
    act(funcs.refresh_delivery_gui)
    act(funcs.refresh_order_stats_gui)
end


function lib.on_init()
    dat = {}
    game.reset_time_played()

    local kitchen = game.get_surface(1)
    kitchen.always_day = true

    local right_border = kitchen.map_gen_settings.width/2 - 1
    local height = kitchen.map_gen_settings.height/2 + 1

    dat.delivery_chest = kitchen.create_entity{
        name = "nkn-delivery-chest",
        force = "player",
        position = {-right_border + 10, -5}
    }
    dat.delivery_zone = rendering.draw_animation{
        animation_speed = 0,
        animation = "nkn-delivery-zone",
        target = {-right_border + 5, 0},
        surface = kitchen,
        render_layer = "lower-object",
    }

    local left_edge = -right_border+5
    for y=-right_border - 5,right_border+6,12 do
        log("sprite @ "..y)
        if (y ~= 0) then
            -- rendering.draw_rectangle{
            --     color = {1, 1, 0, 1},
            --     filled = false,
            --     left_top = {-3,  y-6},
            --     right_bottom = {3, y+6},
            --     surface = kitchen,

            -- }
            rendering.draw_sprite{
                sprite = "nkn-left-wall-shadow",
                target = {left_edge, y},
                surface = kitchen,
                render_layer = "shadow",
            }
        end
    end

    dat.water_mains = kitchen.create_entity{
        name = "infinity-pipe",
        position = {left_edge - 6, 16},
        force = "player",
    }
    dat.water_mains.minable = false
    dat.water_mains.operable = false
    dat.water_mains.set_infinity_pipe_filter{
        name = "water",
        percentage = 90,
        mode = "at-least",
    }

    dat.mains = kitchen.create_entity{
        name = "electric-energy-interface",
        position = {left_edge - 5, 12},
        force = "player",
    }
    dat.mains.minable = false
    dat.mains.operable = false

    dat.mains_distribution = kitchen.create_entity{
        name = "nkn-substation",
        position = {left_edge - 6, 14},
        force = "player",
    }

    dat.market = kitchen.create_entity{
        name = "nkn-market",
        position = {0, -height + 3},
        force = "player",
    }

    local order_slots = {}
    local idle_order_slots = {}
    local index = 1
    for y = -height+3,height,4 do
        local entity = kitchen.create_entity{
            name = "nkn-order-chest",
            force = "player",
            position = {right_border, y}
        }
        local combinator = kitchen.create_entity{
            name = "constant-combinator",
            force = "player",
            position = {right_border, y+1},
        }
        combinator.operable = false
        local slot = {
            chest = entity,
            combinator = combinator,
            state = "idle",
            active_indicator = rendering.draw_sprite{
                sprite = "nkn-stopwatch",
                target = entity,
                target_offset = {0, 0.5},
                surface = kitchen,
                x_scale = 0.2,
                y_scale = 0.2,
                visible = false,
            },
            index = index,
        }
        order_slots[index] = slot
        idle_order_slots[index] = index
        index = index + 1
    end
    dat.order_slots = order_slots
    dat.idle_order_slots = idle_order_slots

    dat.last_order_received = game.ticks_played
    dat.last_express_delivery = game.ticks_played

    dat.offers = {}
    dat.incoming = {
        express = {
            bought = {}, on_the_way = {}, time_of_last_delivery = game.ticks_played,
        },
    }

    dat.today = {
        orders_good = {},
        orders_bad = {},
        orders_total = {},
    }


    sell{price = 5, item = "pipe", count = 10}
    sell{price = 5, item = "pipe-to-ground", count = 1}
    sell{price = 5, item = "transport-belt", count = 10}
    sell{price = 5, item = "underground-belt", count = 4}
    sell{price = 5, item = "splitter", count = 2}
    sell{price = 5, item = "inserter", count = 1}
    sell{price = 10, item = "fast-inserter", count = 1}
    sell{price = 5, item = "wooden-chest", count = 1}

    sell{price = 100, item = "nkn-milling-machine", count = 1}
    sell{price = 100, item = "nkn-mixer", count = 1}
    sell{price = 100, item = "nkn-prep", count = 1}
    sell{price = 100, item = "nkn-baking-oven", count = 1}

    for _,item in pairs(food.items) do
        if item.cost then
            sell{price = item.cost, item = "nkn-"..item.name, count = item.stack_size}
        end
    end

    global.dat = dat
    dat.schedule = {}

    setup_actions()
end

function lib.on_load()
    dat = global.dat

    setup_actions()
end

local function regen_gui(event)
    local player = game.get_player(event.player_index)
    local display_scale = player.display_scale

    local root = player.gui.goal
    root.clear()
    local flow = nil

    local time = root.add{type = "frame", name = "nkn_clock"}
    local time_flow = time.add{type = "flow", direction = "vertical", name = "_"}

    time_flow.style.width = math.max(384 / display_scale, 300)
    time_flow.style.horizontal_align = "center"

    local sprite = time_flow.add{type = "sprite", name = "nkn_clock", sprite = "nkn-clock-1-am"}
    sprite.style.width = 384/display_scale
    sprite.style.height = 384/display_scale

    time_flow.add{type = "label", name = "nkn_clock_text", caption = "00:00"}

    local incoming = root.add{type = "frame", direction = "vertical", name = "incoming"}
    local incoming_flow = incoming.add{type = "flow", direction = "vertical", name = "_"}

    incoming_flow.style.width = 300

    flow = incoming_flow.add{type = "flow", name = "dispatch_status"}
    flow.add{type = "label", caption= "Waiting for dispatch:"}
    flow.add{type = "label", caption= "", name = "nkn_value"}

    flow = incoming_flow.add{type = "flow", name = "delivery_status"}
    flow.add{type = "label", caption= "On the way:"}
    flow.add{type = "label", caption= "", name = "nkn_value"}

    local stats = root.add{type = "frame", direction = "vertical", name = "stats"}
    local stats_flow = stats.add{type = "flow", direction = "vertical", name = "_"}
    stats_flow.style.width = 300

    flow = stats_flow.add{type = "flow", name = "nkn_total"}
    flow.add{type = "label", caption= "Orders received:"}
    flow.add{type = "label", caption= "", name = "nkn_value"}

    flow = stats_flow.add{type = "flow", name = "nkn_good"}
    flow.add{type = "label", caption= "Orders completed:"}
    flow.add{type = "label", caption= "", name = "nkn_value"}

    flow = stats_flow.add{type = "flow", name = "nkn_bad"}
    flow.add{type = "label", caption= "Orders missed:"}
    flow.add{type = "label", caption= "", name = "nkn_value"}
end

local function on_player_created(event)
    local player = game.get_player(event.player_index)

    player.insert({name = "nkn-coin", count = 2000})

    regen_gui(event)

end

local function process_func(func)
    if func.who == "set-frame" then
        set_frame(game.tick, 0, func.what.def, func.what.handle)
    end
end

local function on_tick(event)
    -- Check to see how much the delta between tick and ticks_playerd changes - I think it will only change for editor pause :scream:
    -- if event.tick % 120 == 0 then
        -- game.print(interp("tick: ${tick}, ticks_played: ${ticks_played}, delta = ${delta}", {delta = game.ticks_played - game.tick}, game))
    -- end

    local tick = game.ticks_played
    local scheduled = dat.schedule[tick]
    if scheduled then
        for _,func in pairs(scheduled) do
            process_func(func)
        end
        dat.schedule[tick] = nil
    end

    local slice = tick % 60

    if actions[slice] then
        actions[slice](slice)
    end
end

lib.events = {
    [defines.events.on_player_created] = on_player_created,
    [defines.events.on_tick] = on_tick,
    [defines.events.on_market_item_purchased] = on_sold,
    [defines.events.on_player_display_scale_changed] = regen_gui,

}

handler.add_lib(lib)