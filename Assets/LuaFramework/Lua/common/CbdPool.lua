---
--- Created by Hugo
--- DateTime: 2023/12/16 11:23
---

CbdIndex = {
    self = 1, --table
    bundle = 2, --string
    asset = 3, --string
    type = 4, --user_data
    parent = 5, --GameObject
    callback = 6, --function
    cb_data = 7, --table
    priority = 8, --number
    is_async = 9, --boolean
    prefab = 10, --GameObject
    need_load = 11, --boolean
    time = 12, --number
    source = 13, --GameObject
    target = 14, --GameObject
    state_info = 15, --user_data
    token = 16, --string or number
    position = 17,
    loader = 18, --table
    debug = 19, --string
    reference = 20, --scene_obj
    deliverer = 21, --scene_obj
    effect_data = 22, --table
    part = 23,
    projectile = 24,
    hurt_point = 25,
    from_point = 26,
    transform = 27,
    stop_callback = 28,
    loop = 29,
    forget = 30,
}

---@class CbdPool
CbdPool = {}
CbdPool._callback_data_pool = {}

function CbdPool.CreateCbData()
    local cbd = table.remove(CbdPool._callback_data_pool)
    if cbd == nil then
        cbd = {
            [CbdIndex.bundle] = true,
            [CbdIndex.asset] = true,
            [CbdIndex.callback] = true,
            [CbdIndex.cb_data] = true,
        }
    end
    return cbd
end

function CbdPool.ReleaseCbData(cbd)
    for k, v in pairs(cbd) do
        local typo = type(v)
        if typo == "table" or typo == "userdata" then
            cbd[k] = false
        end
    end
    table.insert(CbdPool._callback_data_pool, cbd)
end