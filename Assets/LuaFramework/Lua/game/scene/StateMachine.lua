---
--- Created by Hugo
--- DateTime: 2023/5/25 16:49
---

---@class StateData
---@field name string
---@field enter function
---@field update function
---@field exit function

---@class StateMachine : BaseClass
---@field now_state StateData
StateMachine = StateMachine or BaseClass()

function StateMachine:__init(obj)
    self.obj = obj
    self.state_list = {}
    self.is_changing = false
    self.now_state = nil
    self.next_state_name = nil
    self.elapse_time = 0
    self.update_duration = 0.2
end

function StateMachine:__delete()
    self.state_list = nil
    self.now_state = nil
    self.obj = nil
end

function StateMachine:SetStateFunc(state_name, enter_func, update_func, exit_func)
    local state = {}
    state.name = state_name
    state.enter = enter_func
    state.update = update_func
    state.exit = exit_func
    self.state_list[state_name] = state
end

function StateMachine:UpdateState(elapse_time)
    self.elapse_time = self.elapse_time + elapse_time
    if self.elapse_time < self.update_duration then
        return
    end

    elapse_time = self.elapse_time
    self.elapse_time = 0

    if self.next_state_name then
        self:ChangeState(self.next_state_name)
    end

    if self.now_state then
        self.now_state.update(self.obj, elapse_time)
    end
end

local _temp_state
function StateMachine:ChangeState(state_name)
    if self.is_changing then
        self.next_state_name = state_name
        return
    end
    self.is_changing = true
    self.next_state_name = nil

    if self.now_state then
        _temp_state = self.now_state
        self.now_state = self.state_list[state_name]
        _temp_state.exit(self.obj)
    else
        self.now_state = self.state_list[state_name]
    end

    if self.now_state then
        self.now_state.enter(self.obj)
    end

    self.is_changing = false
end

function StateMachine:GetStateName()
    return self.now_state and self.now_state.name
end

function StateMachine:IsInState(state_name)
    if self.now_state == nil then
        return false
    end
    return self.now_state.name == state_name
end

