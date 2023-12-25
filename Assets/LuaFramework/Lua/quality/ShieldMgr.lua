---
--- Created by Hugo
--- DateTime: 2023/12/21 11:57
---

require("quality/ShieldConfig")

---@class ShieldMgr : BaseClass
ShieldMgr = ShieldMgr or BaseClass()

function ShieldMgr:__init()
    if ShieldMgr.Instance then
        print_error("[ShieldMgr] attempt to create singleton twice!")
        return
    end
    ShieldMgr.Instance = self

    self.rule_map = {}

    Runner.Instance:AddRunObj(self)
end

function ShieldMgr:__delete()
    Runner.Instance:RemoveRunObj(self)

    ShieldMgr.Instance = nil
end

function ShieldMgr:Update(now_time, delta_time)

end