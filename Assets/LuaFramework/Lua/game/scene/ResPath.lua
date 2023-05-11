---
--- Created by Hugo
--- DateTime: 2023/5/11 10:35
---

---@class ResPath
ResPath = {}

function ResPath.GetRoleModel(res_id)
    if IsNilOrEmpty(res_id) then
        return
    end
    return "actors/role/" .. tostring(res_id) .. "_prefab", tostring(res_id)
end

function ResPath.GetPetModel(res_id)
    if IsNilOrEmpty(res_id) then
        return
    end
    return "actors/pet/" .. tostring(res_id) .. "_prefab", tostring(res_id)
end

function ResPath.GetMonsterModel(res_id)
    if IsNilOrEmpty(res_id) then
        return
    end
    return "actors/monster/" .. tostring(res_id) .. "_prefab", tostring(res_id)
end