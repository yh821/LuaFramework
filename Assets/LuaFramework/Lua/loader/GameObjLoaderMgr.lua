---
--- Created by Hugo
--- DateTime: 2023/12/18 18:31
---

---@class GameObjLoaderMgr : BaseClass
---@field loader_map table<GameObjLoader, boolean>
GameObjLoaderMgr = GameObjLoaderMgr or BaseClass()

function GameObjLoaderMgr:__init()
    if GameObjLoaderMgr.Instance then
        print_error("[GameObjLoaderMgr] attempt to create singleton twice!")
        return
    end
    GameObjLoaderMgr.Instance = self

    self.loader_map = {}
    self.add_list = {}
    self.add_index = 0

    Runner.Instance:AddRunObj(self)
end

function GameObjLoaderMgr:__delete()
    Runner.Instance:RemoveRunObj(self)

    GameObjLoaderMgr.Instance = nil
end

function GameObjLoaderMgr:Update(now_time, delta_time)
    if self.add_index > 0 then
        for i = 1, self.add_index do
            self.loader_map[self.add_index[i]] = true
            self.add_list[i] = EmptyTable
        end
        self.add_index = 0
    end
    for k, _ in pairs(self.loader_map) do
        if k:Update(now_time, delta_time) then
            self.loader_map[k] = nil
        end
    end
end

---@param loader GameObjLoader
function GameObjLoaderMgr:AddTimer(loader)
    self.add_index = self.add_index + 1
    self.add_list[self.add_index] = loader
end