---
--- Created by Hugo
--- DateTime: 2023/12/16 20:34
---

---@class VisibleObj : BaseClass
VisibleObj = VisibleObj or BaseClass()

function VisibleObj:__init()
    self.shield_obj_type = ShieldObjType.InValid
    self.is_deleted = false
end

function VisibleObj:__delete()
    self.is_deleted = true
end