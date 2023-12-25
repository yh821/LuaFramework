---
--- Created by Hugo
--- DateTime: 2023/12/19 22:08
---

---@class AudioMgr : BaseClass
AudioMgr = AudioMgr or BaseClass()

function AudioMgr:__init()
    if AudioMgr.Instance then
        print_error("[AudioMgr] attempt to create singleton twice!")
        return
    end
    AudioMgr.Instance = self

    local audio_mgr_obj = ResMgr.Instance:CreateEmptyGameObj("AudioManager", true)
    local source_pool_obj = ResMgr.Instance:CreateEmptyGameObj("AudioSourcePool", true)

    self.v_audio_mgr_obj = audio_mgr_obj
    self.v_source_pool = AudioSourcePool(audio_mgr_obj.transform, source_pool_obj.transform)

    self.v_ctrl_stop_times = {}
    self.v_ctrl_stop_callback = {}
    self.v_ctrl_audio_items = {}
    self.v_need_update_ctrl = {}

    Runner.Instance:AddRunObj(self)
end

function AudioMgr:__delete()
    Runner.Instance:RemoveRunObj(self)

    ResMgr.Instance:Destroy(self.v_audio_mgr_obj)

    AudioMgr.Instance = nil
end

function AudioMgr:Update()
    for ctrl, stop_time in pairs(self.v_ctrl_stop_times) do
        if stop_time <= Status.NowTime then
            self:StopAudio(ctrl)
        elseif self.v_need_update_ctrl[ctrl] then
            ctrl:Update()
        end
    end
end

local function GetAudioCallBack(obj, cb_data)
    local bundle_name = cb_data[CbdIndex.bundle]
    local asset_name = cb_data[CbdIndex.asset]
    local position = cb_data[CbdIndex.position]
    local transform = cb_data[CbdIndex.transform]
    local callback = cb_data[CbdIndex.callback]
    local stop_callback = cb_data[CbdIndex.stop_callback]
    local loop = cb_data[CbdIndex.loop]
    local forget = cb_data[CbdIndex.forget]
    CbdPool.ReleaseCbData(cb_data)

    if IsNil(obj) then
        return
    end

    if not obj:IsValid() then
        ResPoolMgr.Instance:Release(obj)
        print_error("[AudioMgr] audio is invalid:", bundle_name, asset_name)
        return
    end

    local ctrl = obj:Play(self.v_source_pool)
    if IsNil(obj) then
        ResPoolMgr.Instance:Release(obj)
        print_error("[AudioMgr] ctrl is invalid:", bundle_name, asset_name)
        return
    end

    local left_time = ctrl.LeftTime
    if not loop and left_time <= 0 then
        ResPoolMgr.Instance:Release(obj)
        return
    end

    self.v_ctrl_audio_items[ctrl] = obj

    position = position or Vector3.zero
    ctrl:SetPosition(position)
    ctrl:Play()

    if transform then
        ctrl:SetTransform(transform)
    end

    if not loop then
        self.v_ctrl_stop_times[ctrl] = Status.NowTime + left_time
    end

    if not forget then
        self.v_need_update_ctrl[ctrl] = true
    end

    if callback then
        callback(ctrl, asset_name)
    end

    if stop_callback then
        self.v_ctrl_stop_callback[ctrl] = { callback = stop_callback, asset_name = asset_name }
    end
end

function AudioMgr:Play(bundle_name, asset_name, position, transform, callback, stop_callback, loop, forget)
    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.bundle] = bundle_name
    cbd[CbdIndex.asset] = asset_name
    cbd[CbdIndex.position] = position
    cbd[CbdIndex.transform] = transform
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.stop_callback] = stop_callback
    cbd[CbdIndex.loop] = loop
    cbd[CbdIndex.forget] = forget
    ResPoolMgr.Instance:GetAudio(bundle_name, asset_name, GetAudioCallBack, cbd, true)
end

function AudioMgr:PlayAndForget(bundle_name, asset_name, position, transform, callback, stop_callback, loop)
    self:Play(bundle_name, asset_name, position, transform, callback, stop_callback, loop, true)
end

function AudioMgr:StopAudio(ctrl)
    local audio_item = self.v_ctrl_audio_items[ctrl]
    if not audio_item then
        return
    end
    local audio_stop_callback = self.v_ctrl_stop_callback[ctrl]
    self.v_ctrl_stop_times[ctrl] = nil
    self.v_ctrl_stop_callback[ctrl] = nil
    self.v_ctrl_audio_items[ctrl] = nil
    self.v_need_update_ctrl[ctrl] = nil
    ctrl:FinishAudio()
    ResPoolMgr.Instance:Release(audio_item)

    if audio_stop_callback then
        local callback = audio_stop_callback["callback"]
        local asset_name = audio_stop_callback["asset_name"]
        callback(ctrl, asset_name)
    end
end