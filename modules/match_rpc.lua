local nk = require("nakama")

local function get_match_id(_, _)
    -- local matches = nk.match_list()
    -- local current_match = matches[1]

    -- if current_match == nil then
    --     return nk.match_create("match_control", {})
    -- else
    --     return current_match.match_id
    -- end
    
    return nk.match_create("match_control", {})
end

local function get_code_by_match_id(_, payload)
    -- nk.logger_info('get_code_by_match_id')
    -- local matches = nk.match_list()
    -- nk.logger_info('match_list')
    -- for _, match in ipairs(matches) do
    --     nk.logger_info(match.match_id)
    --     if match.match_id == payload then
    --         return match.code
    --     end
    -- end
    -- return ''

    local match = nk.match_get(payload)
    if match ~= nil then
        return match.label
    end
    return ''
end

local function get_match_id_by_code(_, payload)
    local matches = nk.match_list()
    for _, match in ipairs(matches) do
        if match.label == payload then
            return match.match_id
        end
    end
    return ''
end

nk.register_rpc(get_match_id, "get_match_id")
nk.register_rpc(get_match_id_by_code, 'get_match_id_by_code')
nk.register_rpc(get_code_by_match_id, 'get_code_by_match_id')
