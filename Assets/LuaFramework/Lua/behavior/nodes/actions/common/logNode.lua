﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Leo.
--- DateTime: 2023/4/5 16:13
---

---@class logNode : ActionNode
logNode = BaseClass(ActionNode)

local _print = log
local _error = logError

function logNode:Tick(delta_time)
	if self.data.is_error then
		_error(self.data.msg)
	else
		_print(self.data.msg)
	end
	return eNodeState.success
end
