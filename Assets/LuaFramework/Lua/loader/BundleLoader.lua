---
--- Created by Hugo
--- DateTime: 2023/9/15 10:35
---

---@class BundleLoader : LoaderBase
---@field super LoaderBase
BundleLoader = BundleLoader or BaseClass()

function BundleLoader:__init()
    self.v_lua_manifest_info = { bundleInfos = {} }
    self.v_manifest_info = { bundleInfos = {} }
    self.v_goid_prefab_map = {}
    self.v_goid_go_monitors = {}
    self.v_goid_go_monitor_time = 0

    self.load_priority_type_list = {
        ResLoadPriority.sync,
        ResLoadPriority.ui_high,
        ResLoadPriority.ui_mid,
        ResLoadPriority.ui_low,
        ResLoadPriority.high,
        ResLoadPriority.mid,
        ResLoadPriority.low,
        ResLoadPriority.steal
    }

    self.load_priority_count_list = { 1, 1, 1, 1, 0.9, 0.7, 0.1, 0 }

    self.v_instantiate_count = 0
    self.v_priority_instantiate_queue = {}
    self.v_log_list = {}

    for i, v in ipairs(self.load_priority_type_list) do
        self.v_priority_instantiate_queue[v] = {}
    end
end

function BundleLoader:__delete()
end

function BundleLoader:Update(time, delta_time)
    BundleLoader.super.Update(self, time, delta_time)
    self:__UpdateInstantiate()
    AssetBundleMgr:Update()
    DownloaderMgr:Update()
end