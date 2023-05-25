---
--- Created by Hugo
--- DateTime: 2023/5/13 19:38
---

ResPoolReleasePolicy = {
    min = 0,
    default = 1,
    not_destroy = 2,
    culling = 3,
    destroy = 4,
    max = 5
}

---@class ObjPool
ObjPool = ObjPool or BaseClass()

function ObjPool:__init()
end

function ObjPool:__delete()
end

function ObjPool:Release(obj, policy)
end

function ObjPool:ReleaseInObjId(id)
end