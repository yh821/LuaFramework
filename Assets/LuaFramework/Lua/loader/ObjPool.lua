---
--- Created by Hugo
--- DateTime: 2023/5/13 19:38
---

---@class ObjPool : BaseClass
ObjPool = ObjPool or BaseClass()

function ObjPool:__init()
end

function ObjPool:__delete()
end

function ObjPool:Release(obj, policy)
end

function ObjPool:ReleaseInObjId(id)
end