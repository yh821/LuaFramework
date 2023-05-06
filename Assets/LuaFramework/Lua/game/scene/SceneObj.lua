---
--- Created by Hugo
--- DateTime: 2023/5/6 17:35
---

---@class SceneObj
SceneObj = SceneObj or BaseClass()

SceneObjLayer = GameObject.Find("GameRoot/SceneObjLayer")

function SceneObj:__init(vo, parent_scene)
    self.vo = vo
    self.parent_scene = parent_scene

    self.__CreateDrawObj()

    self.moving = false
end

function SceneObj:__CreateDrawObj()
    local vo = self.vo
    self.draw_obj = DrawObj.New(self, SceneObjLayer.transform)
end

function SceneObj:__delete()
end


