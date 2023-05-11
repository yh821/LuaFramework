---
--- Created by Hugo
--- DateTime: 2023/5/11 15:53
---

---@class attackNode : ActionNode
attackNode = attackNode or BaseClass(ActionNode)

function attackNode:Start()
    local pos_key = self.data and self.data.pos
    local target_pos = self:GetSharedVar(pos_key)
    if not target_pos then
        target_pos = self:GetSharedVar(BtConfig.TargetPosKey)
    end
    if not target_pos then
        return eNodeState.Failure
    end

    local speed = self.data and tonumber(self.data.speed) or 5

    self.draw_obj = self:GetDrawObj()
    if not self.draw_obj then
        return eNodeState.Failure
    end

    self:CancelAttackTimer()
    self.draw_obj:RotateTo(target_pos, 10)
    self.attack_timer = TimerQuest.Instance:AddDelayTimer(function()
        self:SetState(eNodeState.Success)
    end, 1.5) --攻击间隔1.5秒
    self:print("开始攻击:" .. pos_key .. target_pos:ToString())
    self.draw_obj:SetAnimParamMain(DrawObj.AnimParamType.Trigger, "attack")
    return eNodeState.Running
end

function attackNode:CancelAttackTimer()
    if self.attack_timer then
        TimerQuest.Instance:CancelQuest(self.attack_timer)
    end
    self.attack_timer = nil
end

function attackNode:Abort()
    self:CancelAttackTimer()
    if self.draw_obj then
        self.draw_obj:SetAnimParamMain(DrawObj.AnimParamType.ResetTrigger, "attack")
    end
    self:print("<color=red>打断攻击</color>")
    return eNodeState.Failure
end

function attackNode:GetDrawObj()
    ---@type SceneObj
    local scene_obj = self:GetSharedVar(BtConfig.SelfObjKey)
    if scene_obj then
        return scene_obj:GetDrawObj()
    end
end