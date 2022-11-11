local match_control = {}

local nk = require("nakama")


local opCodes = {
    update_board = 1,
    inc_turn = 2,
    set_winner = 3
}

local commands = {}

--math.randomseed(os.time())

commands[opCodes.update_board] = function(data, state)

end

commands[opCodes.inc_turn] = function(data, state)

end

commands[opCodes.set_winner] = function(data, state)

end

local function gen_rand_code()
    local arr = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}
    -- math.randomseed(os.time())
    return arr[math.random(1,26)] .. arr[math.random(1,26)] .. arr[math.random(1,26)] .. arr[math.random(1, 26)]
end

function match_control.match_init(context, params)
    local state = {
        num_presences = 0,
        presences = {},
        state = {},
        --seed = math.random(0, 65535),
        code = gen_rand_code()
    }
    local tick_rate = 10
    local label = state.code

    return state, tick_rate, label
end

function match_control.match_join_attempt(context, dispatcher, tick, state, presence, metadata)
    if state.presences[presence.user_id] ~= nil then
        return state, false, "User already logged in"
    end
    return state, true
end

function match_control.match_join(context, dispatcher, tick, state, presences)
    for _, presence in ipairs(presences) do
        state.presences[presence.user_id] = presence

    end

    state.num_presences = state.num_presences + 1

    return state
end

function match_control.match_leave(context, dispatcher, tick, state, presences)
    for _, presence in ipairs(presences) do
        local new_objects = {
            {
                collection = "player_data",
                key = "position_" .. state.names[presence.user_id],
                user_id = presence.user_id,
                value = state.positions[presence.user_id]
            }
        }
        -- nk.storage_write(new_objects)

        state.presences[presence.user_id] = nil
    end

    state.num_presences = state.num_presences - 1

    if state.num_presences == 0 then
        return nil
    else
        return state
    end
end

function match_control.match_loop(context, dispatcher, tick, state, messages)
    for _, message in ipairs(messages) do
        local op_code = message.op_code

        local decoded = nk.json_decode(message.data)

        local command = commands[op_code]
        if command ~= nil then
            commands[op_code](decoded, state)
        end

        --if op_code == opCodes.do_spawn then
    end


    local data = {
    }
    local encoded = nk.json_encode(data)

    dispatcher.broadcast_message(opCodes.update_state, encoded)

    return state
end

function match_control.match_terminate(_, _, _, state, _)
    local new_objects = {}
    for k, position in pairs(state.positions) do
        table.insert(
            new_objects,
            {
                collection = "player_data",
                key = "position_" .. state.names[k],
                user_id = k,
                value = position
            }
        )
    end

    -- nk.storage_write(new_objects)

    return state
end

return match_control
