---
--- Created by Hugo
--- DateTime: 2023/5/25 17:29
---

SceneObjState = {
    idle = "idle",
    move = "run",
    attack = "attack",
    hurt = "hurt",
    dead = "die",
}

---@class Character : SceneObj
---@field state_machine StateMachine
Character = Character or BaseClass(SceneObj)

function Character:__init()
    self.state_machine = StateMachine.New(self)

    self.state_machine:SetStateFunc(SceneObjState.idle, self.EnterIdleState, self.UpdateIdleState, self.ExitIdleState)
    self.state_machine:SetStateFunc(SceneObjState.move, self.EnterMoveState, self.UpdateMoveState, self.ExitMoveState)
    self.state_machine:SetStateFunc(SceneObjState.attack, self.EnterAttackState, self.UpdateAttackState, self.ExitAttackState)
end

function Character:__delete()
end

function Character:OnEnterScene()
    Character.super.OnEnterScene(self)

    self:ChangeState(SceneObjState.idle)
end

function Character:Update(realtime, unscaledDeltaTime)
    Character.super.Update(self, realtime, unscaledDeltaTime)
    self.state_machine:UpdateState(unscaledDeltaTime)
end

function Character:ChangeState(state_name)
    self.state_machine:ChangeState(state_name)
end

function Character:EnterIdleState()
end
function Character:UpdateIdleState(elapse_time)
end
function Character:ExitIdleState()
end

function Character:EnterMoveState()
end
function Character:UpdateMoveState(elapse_time)
end
function Character:ExitMoveState()
end

function Character:EnterAttackState()
end
function Character:UpdateAttackState(elapse_time)
end
function Character:ExitAttackState()
end