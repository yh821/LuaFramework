---
--- Created by Hugo
--- DateTime: 2023/5/25 19:55
---

---@class SceneLoader : BaseClass
SceneLoader = SceneLoader or BaseClass()

function SceneLoader:__init()
    self.v_is_loading = false
    self.v_bundle_name = nil
    self.v_asset_name = nil
    self.v_loaded_bundle_name = nil
end

function SceneLoader:Destroy()
end

function SceneLoader:Update()
    if not self.v_is_loading then
        if self.not_need_load then
            if self.v_callback then
                local callback = self.v_callback
                self.v_callback = nil
                callback(true)
            end
            self.not_need_load = nil
        end
        return
    end

    if self.v_load_scene_op and self.v_load_scene_op.isDone then
        self.v_load_scene_op = nil
        self:OnLoadLevelComplete(self.v_bundle_name)
    end
end

function SceneLoader:OnLoadLevelComplete(bundle_name)
    self.v_loaded_bundle_name = bundle_name
    self.v_is_loading = false
    if self.v_callback then
        local callback = self.v_callback
        self.v_callback = nil
        callback(true)
    end
    self:TryNextLoad()
end

function SceneLoader:TryNextLoad()
    if self.v_bundle_name == nil then
        return
    end
    if self.v_need_reload then
        self.v_need_reload = false
        if self.v_is_async then
            self:LoadSceneAsync(self.v_bundle_name, self.v_asset_name, self.v_load_mode, self.v_next_callback, true)
        else
            self:LoadSceneSync(self.v_bundle_name, self.v_asset_name, self.v_load_mode, self.v_next_callback, true)
        end
    end
end

function SceneLoader:LoadSceneAsync(bundle_name, asset_name, load_mode, callback, force)
    asset_name = string.lower(asset_name)
    if not force and self:IsSameScene(bundle_name, asset_name) then
        self.not_need_load = true
        self.v_callback = callback
        return
    end

    self.v_bundle_name = bundle_name
    self.v_asset_name = asset_name
    self.v_load_mode = load_mode
    self.v_next_callback = nil
    self.v_need_reload = false
    self.v_is_async = true

    if self.v_is_loading then
        self.v_next_callback = callback
        self.v_need_reload = true
        return
    end

    self.v_callback = callback
    self.v_is_loading = true
    self.v_load_scene_op = nil

    BundleCacheMgr.Instance:SetOverrideCacheTime(bundle_name, 0)
    ResMgr.Instance:LoadUnitySceneAsync(bundle_name, asset_name, load_mode, function(load_scene_op)
        if not self:IsSameScene(bundle_name, asset_name) then
            ResMgr.Instance:UnloadScene(bundle_name)
            return
        end

        if load_scene_op == nil then
            self.v_bundle_name = nil
            self.v_asset_name = nil
            self.v_is_loading = false
            print_error("[SceneLoader]异步加载场景失败:", bundle_name, asset_name)
            if self.v_callback then
                self.v_callback(false)
                self.v_callback = nil
            end
            return
        end

        self.v_load_scene_op = load_scene_op
    end)
end

function SceneLoader:LoadSceneSync(bundle_name, asset_name, load_mode, callback, force)
    asset_name = string.lower(asset_name)
    if not force and self:IsSameScene(bundle_name, asset_name) then
        self.not_need_load = true
        self.v_callback = callback
        return
    end

    self.v_bundle_name = bundle_name
    self.v_asset_name = asset_name
    self.v_load_mode = load_mode
    self.v_next_callback = nil
    self.v_need_reload = false
    self.v_is_async = false

    if self.v_is_loading then
        self.v_next_callback = callback
        self.v_need_reload = true
        return
    end

    self.v_callback = callback
    self.v_is_loading = true
    self.v_load_scene_op = nil

    BundleCacheMgr.Instance:SetOverrideCacheTime(bundle_name, 0)
    ResMgr.Instance:LoadUnitySceneSync(bundle_name, asset_name, load_mode, function(is_succ)
        if not is_succ then
            self.v_bundle_name = nil
            self.v_asset_name = nil
            self.v_is_loading = false
            print_error("[SceneLoader]同步加载场景失败:", bundle_name, asset_name)
            if self.v_callback then
                self.v_callback(false)
                self.v_callback = nil
            end
            return
        end

        if not self:IsSameScene(bundle_name, asset_name) then
            if is_succ then
                ResMgr.Instance:UnloadScene(bundle_name)
            end
            self.v_is_loading = false
            self:TryNextLoad()
            return
        end

        self:OnLoadLevelComplete(bundle_name)
    end)
end

function SceneLoader:Destroy()
    if self.v_loaded_bundle_name then
        ResMgr.Instance:UnloadScene(self.v_loaded_bundle_name)
    end
    self.v_loaded_bundle_name = nil
    self.v_bundle_name = nil
    self.v_asset_name = nil
    self.v_need_reload = nil
end

function SceneLoader:IsSameScene(bundle_name, asset_name)
    return self.v_bundle_name == bundle_name and self.v_asset_name == asset_name
end