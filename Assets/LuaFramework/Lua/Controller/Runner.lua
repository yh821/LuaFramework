﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2023/1/3 17:44
---
Runner = Runner or BaseClass()

Status = {
	NowFrame = 0,
	NowTime = 0,
	ElapseTime = 0,
	NowScaleTime = 0,
	ElapseScaleTime = 0,
	IsEditor = UnityEngine.Application.isEditor,
}

Runner.frame_count = 0
local _priority_max = 16

function Runner:__init()
	if Runner.Instance then
		logError("[Runner] attempt to create singleton twice!")
		return
	end
	Runner.Instance = self

	self.all_run_obj_list = {}
	self.id_count = 0

	self.priority_run_obj_list = {}
	for i = 1, 16 do
		table.insert(self.priority_run_obj_list, {})
	end
end

function Runner:__delete()
	Runner.Instance = nil
end

function Runner:Update(deltaTime, unscaledDeltaTime)
	local realtime = UnityEngine.Time.realtimeSinceStartup
	Status.NowTime = realtime
	Status.NowFrame = UnityEngine.Time.frameCount
	Status.ElapseTime = unscaledDeltaTime
	Status.NowScaleTime = UnityEngine.Time.time
	Status.ElapseScaleTime = UnityEngine.Time.deltaTime
	for i = 1, _priority_max do
		local priority_tbl = self.priority_run_obj_list[i]
		for _, v in pairs(priority_tbl) do
			v:Update(realtime, unscaledDeltaTime)
		end
	end
	Runner.frame_count = Runner.frame_count + 1
end

function Runner:AddRunObj(run_obj, priority_level)
	local obj = self.all_run_obj_list[run_obj]
	if nil ~= obj then
		return false
	end

	if not run_obj.Update then
		logError("Runner:AddRunObj try to add a obj not have Update method!")
	end

	self.id_count = self.id_count + 1
	priority_level = priority_level or _priority_max
	self.all_run_obj_list[run_obj] = {priority_level, self.id_count}
	self.priority_run_obj_list[priority_level][self.id_count] = run_obj
end

function Runner:RemoveRunObj(run_obj)
	local info = self.all_run_obj_list[run_obj]
	if info then
		self.all_run_obj_list[run_obj] = nil
		self.priority_run_obj_list[info[1]][info[2]] = nil
	end
end

function Runner:IsExistRunObj(run_obj)
	return nil ~= self.all_run_obj_list[run_obj]
end
