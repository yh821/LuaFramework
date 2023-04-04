﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2023/4/4 23:04
---

require("behavior/base/taskNode")
require("behavior/base/behaviorTree")
require("behavior/base/parentNode")
require("behavior/base/compositeNode")
require("behavior/base/decoratorNode")
require("behavior/base/conditionNode")
require("behavior/base/actionNode")

AiConfig = {
	scene_obj = "scene_obj",
}

animatorStateEnum = {
	eIdle = 0,
	eWalk = 1,
}

playStateEnum = {
	eStart = 0,
	eEnd = 1,
}

behaviorStateEnum = {
	eIdle = 0, --空闲
	eClick = 1, --点中
}