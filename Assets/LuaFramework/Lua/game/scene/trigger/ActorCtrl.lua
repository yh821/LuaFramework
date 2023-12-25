---
--- Created by Hugo
--- DateTime: 2023/6/10 16:57
---

require("game/scene/trigger/MultiCallBackHub")

---@class ActorCtrl : BaseClass
ActorCtrl = ActorCtrl or BaseClass()

local TypeProjectile = typeof(Projectile)
local TypeEffectController = typeof(EffectController)

local HurtPositionEnum = {
    Root = 0,
    HurtPoint = 1,
}

local HurtRotationEnum = {
    Target = 0,
    HitDirection = 1,
}

function ActorCtrl:__init(actor_trigger)
    self.actor_trigger = actor_trigger
end

function ActorCtrl:__delete()
    self.is_deleted = true
    if self.actor_trigger then
        if not self.actor_trigger.__is_deleted__ then
            self.actor_trigger:DeleteMe()
        end
        self.actor_trigger = nil
    end
end

function ActorCtrl:StopEffects()
    if self.actor_trigger then
        self.actor_trigger:StopEffects()
        self.actor_trigger = nil
    end
end

function ActorCtrl:SetEffectSpeed(speed)
    if self.actor_trigger then
        self.actor_trigger:SetEffectSpeed(speed)
    end
end

function ActorCtrl:SetPrefabData(data)
    self.prefab_data = data
end

function ActorCtrl:GetPrefabData()
    return self.prefab_data
end

function ActorCtrl:PlayProjectile(main_part_obj, action, root, hurt_point, callback, cb_data, offset_pos, key)
    local prefab_data = self:GetPrefabData()
    local find = false
    if prefab_data and prefab_data.actorController then
        local projectiles = prefab_data.actorController.projectiles
        for k, projectile in pairs(projectiles) do
            if projectile.Action == action and next(projectile.Projectile) then
                self:PlayProjectileImpl(main_part_obj, projectile, root, hurt_point, callback, cb_data, offset_pos, key and k .. key or k)
                find = true
                break
            end
        end
    end
    if not find then
        if callback then
            callback(cb_data)
        end
    end
end

local function DelayPlayProjectile(cb_data)
    local self = cb_data[CbdIndex.self]
    local main_part = cb_data[CbdIndex.part]
    local projectile = cb_data[CbdIndex.projectile]
    local hurt_point = cb_data[CbdIndex.hurt_point]
    local from_point = cb_data[CbdIndex.from_point]
    local callback = cb_data[CbdIndex.callback]
    local cbd = cb_data[CbdIndex.cb_data]
    local key = cb_data[CbdIndex.token]
    CbdPool.ReleaseCbData(cb_data)

    if self.is_deleted then
        return
    end
    self:PlayProjectileWithEffect(main_part, projectile, hurt_point, from_point, callback, cbd, key)
end

function ActorCtrl:PlayProjectileImpl(main_part_obj, projectile, root, hurt_point, callback, cb_data, offset_pos, key)
    if self.actor_trigger and self.actor_trigger:EnableEffect() and main_part_obj then
        local from_trans
        local from_pos
        if IsNilOrEmpty(projectile.FromPosHierarchyPath) then
            from_trans = main_part_obj.transform
        else
            from_trans = main_part_obj.transform:Find(projectile.FromPosHierarchyPath)
        end
        from_pos = from_trans.position
        if offset_pos then
            from_pos = Vector3Pool.Sub(from_pos, offset_pos)
        end
        if projectile.DelayProjectileEff <= 0 then
            self:PlayProjectileWithEffect(main_part_obj, projectile, hurt_point, from_pos, callback, cb_data, key)
        else
            local cbd = CbdPool.CreateCbData()
            cbd[CbdIndex.self] = self
            cbd[CbdIndex.part] = main_part_obj
            cbd[CbdIndex.projectile] = projectile
            cbd[CbdIndex.hurt_point] = hurt_point
            cbd[CbdIndex.from_point] = from_pos
            cbd[CbdIndex.callback] = callback
            cbd[CbdIndex.cb_data] = cb_data
            cbd[CbdIndex.token] = key
            TimerQuest.Instance:AddDelayTimer(DelayPlayProjectile, projectile.DelayProjectileEff, cbd)
        end
    else
        self:PlayProjectileWithoutEffect(callback, cb_data)
    end

end

local function LoadProjectileCallBack(obj, cb_data)
    local async_loader = cb_data[CbdIndex.loader]
    local main_part_obj = cb_data[CbdIndex.part]
    local projectile = cb_data[CbdIndex.projectile]
    local hurt_point = cb_data[CbdIndex.hurt_point]
    local from_pos = cb_data[CbdIndex.from_point]
    local callback = cb_data[CbdIndex.callback]
    local cbd = cb_data[CbdIndex.cb_data]
    CbdPool.ReleaseCbData(cb_data)

    if IsNil(obj) then
        return
    end

    if main_part_obj == nil or IsNil(main_part_obj.transform) then
        async_loader:Destroy()
        return
    end

    local instance = obj:GetComponent(TypeProjectile)
    if instance == nil then
        async_loader:Destroy()
        if callback then
            callback(cbd)
        end
        return
    end

    if not IsNil(hurt_point) and hurt_point.transform then
        local direction = from_pos - hurt_point.transform.position
        direction.y = 0
        if direction ~= Vector3.zero then
            instance.transform:SetPositionAndRotation(from_pos, Quaternion.LookRotation(direction))
        end
    else
        instance.transform.position = from_pos
    end

    if IsNil(hurt_point) or IsNil(hurt_point.transform) then
        async_loader:Destroy()
        return
    end

    instance.transform.localScale = main_part_obj.transform.lossyScale

    instance:Play(
            main_part_obj.transform.lossyScale,
            hurt_point.transform,
            main_part_obj.gameObject.layer,
            function()
                if callback then
                    callback(cbd)
                end
            end,
            function()
                async_loader:SetObjAliveTime(projectile.DeleteProjectileDelay)
            end)
    local effect_ctrl = obj:GetComponent(TypeEffectController)
    if effect_ctrl then
        effect_ctrl:WaitFinish(function()
            async_loader:Destroy()
        end)
    end
end

function ActorCtrl:RemoveOnPlayProjectileWithEffects(token)
    if not self.playProjectileWithEffectCb then
        print_error("[ActorCtrl]RemoveOnPlayProjectileWithEffects, invoked!")
        return
    end
    self.playProjectileWithEffectCb:RemoveCallBack(token)
end

function ActorCtrl:SetOnPlayProjectileWithEffect(callback)
    if not self.playProjectileWithEffectCb then
        ---@type MultiCallBackHub
        self.playProjectileWithEffectCb = MultiCallBackHub.New()
    end
    return self.playProjectileWithEffectCb:AddCallBack(callback)
end

function ActorCtrl:LoadByExternal(bundle_name, asset_name, cb_data)
    local loader = cb_data[CbdIndex.loader]
    loader:Load(bundle_name, asset_name, LoadProjectileCallBack, cb_data)
end

function ActorCtrl:PlayProjectileWithEffect(main_part_obj, projectile, hurt_point, from_pos, callback, cb_data, key)
    local bundle_name = projectile.Projectile.BundleName
    local asset_name = projectile.Projectile.AssetName
    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(asset_name) then
        return
    end

    local async_loader = LoadUtil.AllocAsyncLoader(self, "projectile" .. key)
    async_loader:SetIsUseObjPool(true)
    async_loader:SetObjAliveTime(5) --5秒后销毁
    async_loader:SetParent(GEffectLayer)

    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.loader] = async_loader
    cbd[CbdIndex.part] = main_part_obj
    cbd[CbdIndex.projectile] = projectile
    cbd[CbdIndex.hurt_point] = hurt_point
    cbd[CbdIndex.from_point] = from_pos
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.cb_data] = cb_data
    if self.playProjectileWithEffectCb then
        self.playProjectileWithEffectCb:invoke(self, bundle_name, asset_name, cbd)
    end
    async_loader:Load(bundle_name, asset_name, LoadProjectileCallBack, cbd)
end

local function DelayPlayProjectileWithoutEffect(cb_data)
    local self = cb_data[CbdIndex.self]
    local callback = cb_data[CbdIndex.callback]
    local cbd = cb_data[CbdIndex.cb_data]
    CbdPool.ReleaseCbData(cb_data)

    if self.is_deleted then
        return
    end

    if callback then
        callback(cbd)
    end
end

function ActorCtrl:PlayProjectileWithoutEffect(callback, cb_data)
    local cbd = CbdPool.CreateCbData()
    cbd[CbdIndex.self] = self
    cbd[CbdIndex.callback] = callback
    cbd[CbdIndex.cb_data] = cb_data
    TimerQuest.Instance:AddDelayTimer(DelayPlayProjectileWithoutEffect, 0.5, cbd)
end

function ActorCtrl:PlayHurtShow(action, root, hurt_point, callback, cb_data)
    local prefab_data = self:GetPrefabData()
    local find = false
    if prefab_data and prefab_data.actorController then
        local hurts = prefab_data.actorController.hurts
        for _, hurt in pairs(hurts) do
            if hurt.Action == action then
                if next(hurt.Projectile) then
                    self:PlayHurtEffect(hurt, root, hurt_point)
                end
                if hurt.HitCount > 0 then
                    self:PlayHitEffect(hurt, root, hurt_point, callback, cb_data)
                else
                    if callback then
                        callback(cb_data)
                    end
                end
                find = true
                break
            end
        end
    end
    if not find then
        if callback then
            callback(cb_data)
        end
    end
end

function ActorCtrl:PlayHurtEffect(data, root, hurt_point)
    local bundle_name = data.HurtEffect.BundleName
    local asset_name = data.HurtEffect.AssetName

    if IsNilOrEmpty(bundle_name) or IsNilOrEmpty(asset_name) then
        return
    end

    local async_loader = LoadUtil.AllocAsyncLoader(self, "hurt_effect")
    async_loader:SetIsUseObjPool(true)
    async_loader:SetObjAliveTime(5) --5秒后销毁
    async_loader:Load(bundle_name, asset_name, function(obj)
        if IsNil(obj) then
            return
        end

        local instance = obj:GetOrAddComponent(TypeEffectController)
        if instance == nil then
            async_loader:Destroy()
            return
        end

        instance:Reset()
        instance.enabled = true

        local target_pos = root
        if data.HurtPosition == HurtPositionEnum.HurtPoint then
            target_pos = hurt_point
        end

        if data.HurtRotation == HurtRotationEnum.Target then
            instance.transform:SetPositionAndRotation(target_pos.position, target_pos.rotation)
        else
            local direction = target_pos.position - obj.transform.position
            direction.y = 0
            if direction ~= Vector3.zero then
                instance.transform:SetPositionAndRotation(target_pos.position, Quaternion.LookRotation(direction))
            end
        end

        instance:WaitFinish(function()
            async_loader:Destroy()
        end)
        instance:play()
    end)
end

function ActorCtrl:PlayHitEffect(data, root, hurt_point, callback, cb_data)
    if root == nil or hurt_point == nil then
        return
    end

    local bundle_name = data.HitEffect.BundleName
    local asset_name = data.HitEffect.AssetName

    local function LoadEffectRes(index)
        local async_loader = LoadUtil.AllocAsyncLoader(self, "hit_effect_" .. index)
        async_loader:SetIsUseObjPool(true)
        async_loader:SetObjAliveTime(5) --5秒后销毁
        async_loader:Load(bundle_name, asset_name, function(obj)
            if IsNil(obj) then
                return
            end

            local instance = obj:GetOrAddComponent(TypeEffectController)
            if instance == nil then
                async_loader:Destroy()
                return
            end

            instance:Reset()
            instance.enabled = true

            local target_pos = root
            if data.HurtPosition == HurtPositionEnum.HurtPoint then
                target_pos = hurt_point
            end

            if data.HurtRotation == HurtRotationEnum.Target then
                instance.transform:SetPositionAndRotation(target_pos.position, target_pos.rotation)
            else
                local direction = target_pos.position - obj.transform.position
                direction.y = 0
                if direction ~= Vector3.zero then
                    instance.transform:SetPositionAndRotation(target_pos.position, Quaternion.LookRotation(direction))
                end
            end

            instance:WaitFinish(function()
                async_loader:Destroy()
            end)
            instance:play()
        end)
    end

    for i = 0, data.HitCount - 1 do
        if next(data.HitEffect) then
            if i <= 0 then
                LoadEffectRes(i)
            else
                TimerQuest.Instance:AddDelayTimer(function()
                    if self.is_deleted then
                        return
                    end
                    LoadEffectRes(i)
                end)
            end
        end
        if callback then
            callback(cb_data)
        end
    end
end

function ActorCtrl:PlayHurt(action, per_hit, cb_data)
    local prefab_data = self:GetPrefabData()
    local find = false
    if prefab_data and prefab_data.actorController then
        local hurts = prefab_data.actorController.hurts
        for _, hurt in pairs(hurts) do
            if hurt.Action == action then
                if hurt.HitCount > 0 then
                    self:PlayHit(hurt, per_hit, cb_data)
                else
                    per_hit(1, cb_data)
                end
                find = true
                break
            end
        end
    end
    if not find then
        if per_hit then
            per_hit(1, cb_data)
        end
    end
end

function ActorCtrl:PlayHit(hurts, per_hit, cb_data)
    local hit_count = hurts.HitCount
    local hit_interval = Split(hurts.HitInterval or "", '|')
    local random = Split(hurts.HitProportion or "", '|')
    local total = 1

    local function SubHit(fun, ram, tot, cbd)
        local percent = ram / tot
        fun(percent, cbd)
    end

    for i = 1, hit_count do
        TimerQuest.Instance:AddDelayTimer(function()
            SubHit(per_hit, tonumber(random[i]) or 1 / hit_count, total, cb_data)
        end, tonumber(hit_interval[i]) or 0)
    end
end

function ActorCtrl:PlayBeHurt(root)
    local prefab_data = self:GetPrefabData()
    if prefab_data and prefab_data.actorController then
        local be_hurt_effect = prefab_data.actorController.beHurtEffect
        if next(be_hurt_effect) and not be_hurt_effect.IsEmpty then
            local bundle_name = be_hurt_effect.BundleName
            local asset_name = be_hurt_effect.AssetName
            if not IsNilOrEmpty(bundle_name) and not IsNilOrEmpty(asset_name) then
                self:PlayBeHitEffect(bundle_name, asset_name, root, be_hurt_effect.beHurtPosition, be_hurt_effect.heHurtAttach)
            end
        end
    end
end

function ActorCtrl:PlayBeHitEffect(bundle_name, asset_name, root, position, attached)
    local async_loader = LoadUtil.AllocAsyncLoader(self, "be_hit_effect_" .. asset_name)
    async_loader:SetIsUseObjPool(true)
    async_loader:SetObjAliveTime(5) --5秒后销毁
    async_loader:Load(bundle_name, asset_name, function(obj)
        if obj == nil then
            return
        end
        local instance = obj:GetComponent(TypeEffectController)
        if instance == nil then
            async_loader:Destroy()
            return
        end

        instance:Reset()
        instance.enabled = true

        if position == nil then
            position = root.transform
        end

        if attached then
            instance.transform:SetParent(position, false)
        else
            instance.transform:SetPositionAndRotation(position.position, position.rotation)
        end

        instance:WaitFinish(function()
            async_loader:Destroy()
        end)
        instance:play()
    end)
end

function ActorCtrl:PlaySound(data)
    local asset_name = data.soundAudioAsset.AssetName
    TimerQuest.Instance:AddDelayTimer(function()
        AudioMgr.Instance:PlayAndForget(data.soundAudioAsset.BundleName, asset_name)
    end, data.soundDelay)
end

function ActorCtrl:TriggerCameraFOV()
    if MainCamera and MainCamera.main.isActiveAndEnabled then
        self.fadeTime = 0
    end
end

function ActorCtrl:Blink(obj, fadeIn, fadeHold, fadeOut, color)
    if obj then
        local actorRender = obj.transform:GetOrAddComponent(typeof(ActorRender))
        color = color or color_blink
        actorRender:PlayBlinkEffect(color)
    end
end