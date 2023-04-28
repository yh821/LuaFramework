﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yuanhuan.
--- DateTime: 2023/4/4 22:03
---

require("behavior/behaviorManager")

---@class AiManager
---@field _bt_list BehaviorTree[]
AiManager = AiManager or BaseClass()

function AiManager:__init()
	if AiManager.Instance then
		print_error("[AiManager] attempt to create singleton twice!")
		return
	end
	AiManager.Instance = self

	self._bt_list = {}

	Runner.Instance:AddRunObj(self, 9)
end

function AiManager:__delete()
	Runner.Instance:RemoveRunObj(self)

	self._bt_list = nil

	AiManager.Instance = nil
end

function AiManager:Update(realtime, delta_time)
	BehaviorManager:Update(delta_time)
end

function AiManager:SwitchTick()
	BehaviorManager:SwitchTick()
end

---@return BehaviorTree 一个实体只能绑定一个行为树
function AiManager:BindBT(gameObject, file)
	local bt = BehaviorManager:BindBehaviorTree(gameObject, file)
	if not bt then
		return
	end
	bt:SetSharedVar(AiConfig.gameObjKey, gameObject)
	self._bt_list[gameObject] = bt
	return bt
end

function AiManager:UnBindBT(gameObject)
	BehaviorManager:UnBindBehaviorTree(gameObject)
	self._bt_list[gameObject] = nil
end
