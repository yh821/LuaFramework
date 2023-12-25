---
--- Created by Hugo
--- DateTime: 2023/5/9 13:28
---

---@class ResMgr : BaseClass
---@field Instance LoaderBase
ResMgr = ResMgr or BaseClass()

function ResMgr:__init()
    if ResMgr.Instance then
        print_error("[ResManager] attempt to create singleton twice!")
        return
    end
    if GAME_ASSET_BUNDLE then
        ResUtil.InitEncryptKey()
        if ResUtil.is_ios_encrypt_asset then
            ResUtil.SetBaseCachePath(string.format("%s/%s", UnityApplication.persistentDataPath, EncryptMgr.GetEncryptPath("BundleCache")))
        end
        require("loader/BundleLoader")
        ResMgr.Instance = BundleLoader.New()
    else
        require("loader/SimulationLoader")
        ResMgr.Instance = SimulationLoader.New()
    end

    Runner.Instance:AddRunObj(ResMgr.Instance)
end

function ResMgr:__delete()
    Runner.Instance:RemoveRunObj(ResMgr.Instance)
    ResMgr.Instance = nil
end