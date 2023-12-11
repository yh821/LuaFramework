---
--- Created by Hugo
--- DateTime: 2023/6/10 17:35
---

local TypeEffectControl = typeof(EffectControl)

---@class ActorTriggerEffect : ActorTriggerBase
ActorTriggerEffect = ActorTriggerEffect or BaseClass(ActorTriggerBase)

function ActorTriggerEffect:__init()
    self.anim_name = nil
    self.transform = nil
    self.enabled = true
    self.target = nil
    self.is_modify_mask = false
    self.is_use_low_quality = false
    self.ui3d_model = nil
    self.effects = {}
end

function ActorTriggerEffect:__delete()
    self.effects = nil
    self.actorTrigger = nil
end

function ActorTriggerEffect:InitData(data, is_modify_mask, is_use_low_quality)
    ActorTriggerBase.InitData(self, data)
    self.transform = nil
    self.enabled = true
    self.target = nil
    self.is_modify_mask = is_modify_mask
    self.is_use_low_quality = is_use_low_quality
end

function ActorTriggerEffect:Reset()
    if self.__game_obj_loaders then
        ReleaseGameObjLoaders(self)
    end
    if self.__res_loaders then
        ReleaseResLoaders(self)
    end
    self.actorTrigger = nil
    self.transform = nil
    self.target = nil
    self.ui3d_model = nil
    self.effect_custom_scale = nil
    self.target_effect_custom_scale = nil
    self.effect_custom_rotation = nil
    self.effect_async_loader = nil
    self.effect_ctrl = nil
    self.is_modify_mask = false
    self.override_root = nil
    ActorTriggerBase.Reset(self)
end

function ActorTriggerEffect:SetOverrideRoot(root)
    self.override_root = root
end

function ActorTriggerEffect:SetUI3dModel(ui3d_model)
    self.ui3d_model = ui3d_model
end

function ActorTriggerEffect:OnEventTriggered(source, target, state_info)
    if state_info and state_info.pos_table then
        for i, v in pairs(state_info.pos_table) do
            local data = { play_pos = v }
            self:OnEventTriggeredImpl(source, target, data)
        end
    else
        self:OnEventTriggeredImpl(source, target, state_info)
    end
end

local default_layer = UnityEngine.LayerMask.NameToLayer("Default")
local ui3d_layer = UnityEngine.LayerMask.NameToLayer("UI3D")
local TriggerEffectCount = 0

local function EffectLoadCallBack(obj, cb_data)
    local self = cb_data[1]
    local async_loader = cb_data[2]
    local reference = cb_data[3]
    local deliverer = cb_data[4]
    local effect_data = cb_data[5]
    local state_info = cb_data[7]
    ActorCtrl.ReleaseCbData(cb_data)

    if IsNil(obj) then
        return
    end
    local effect = obj:GetComponent(TypeEffectControl)
    if effect == nil then
        async_loader:Destroy()
        return
    end
    self.effects[effect] = async_loader
    --reference 释放者
    if not IsNil(reference) and not IsNil(deliverer) then
        if effect_data.isAttach then
            --特效附着在释放者身上
            effect.transform:SetParent(reference)
            --同步释放者旋转角度
            if effect_data.isRotation then
                local reference_position = Transform.GetPositionOnce(reference)
                local deliverer_position = Transform.GetPositionOnce(deliverer)
                local direction = Vector3Pool.Sub(reference_position, deliverer_position)
                direction.y = 0
                if Vector3Pool.Distance(direction, false) <= 1e-6 then
                    local deliverer_forward = Transform.GetForwardOnce(deliverer)
                    direction = Vector3Pool.Sub(Vector3Pool.Mul(deliverer_forward, 1000), deliverer_position)
                    direction.y = 0
                end
                effect.transform.position = deliverer_position
                effect.transform.rotation = Vector3Pool.LookRotation(direction)
            else
                effect.transform.localPosition = Vector3Pool.Get(0, 0, 0)
                effect.transform.localRotation = Quaternion.identity
            end

            if effect_data.ignoreParentScale then
                effect.transform.localScale = Vector3Pool.Get(1, 1, 1)
            else
                effect.transform.localScale = reference.localScale
            end
        else
            local deliverer_position = Transform.GetPositionOnce(deliverer)
            local deliverer_forward = Transform.GetForwardOnce(deliverer)
            --position
            if effect_data.playerAtTarget then
                --目标身上播放
                if deliverer and not IsNil(deliverer.gameObject) then
                elseif state_info and state_info.dir_pos then
                    effect.transform.position = Vector3Pool.Get(state_info.dir_pos.x, deliverer_position.y, state_info.dir_pos.z)
                else
                    effect.transform.position = Vector3Pool.Add(deliverer_position, Vector3Pool.Mul(deliverer_forward, 4))
                end
            else
                local pos = deliverer_position
                if state_info and state_info.off_pos then
                    pos = Vector3Pool.Add(pos, state_info.off_pos)
                elseif state_info and state_info.play_pos then
                    pos = state_info.play_pos
                end
                effect.transform.position = pos
            end

            --rotation
            if effect_data.playerAtTarget == false and effect_data.isRotation then
                local direction = Vector3Pool.Sub(Vector3Pool.Add(deliverer_position, Vector3Pool.Mul(deliverer_forward, 5)), deliverer_position)
                if state_info and state_info.play_pos then
                    direction = Vector3Pool.Sub(state_info.play_pos, deliverer_position)
                elseif state_info and state_info.dir_pos then
                    direction = Vector3Pool.Sub(state_info.dir_pos, deliverer_position)
                end
                direction.y = 0
                if direction.x == 0 and direction.z == 0 then
                    direction.x = 0.1
                end
                effect.transform.rotation = Vector3Pool.LookRotation(direction)
            end

            --scale
            local scale
            if effect_data.ignoreParentScale then
                if self.effect_size_scale then
                    scale.x = scale.x * self.effect_size_scale.x
                    scale.y = scale.y * self.effect_size_scale.y
                    scale.z = scale.z * self.effect_size_scale.z
                else
                    scale = Vector3Pool.Get(1, 1, 1)
                end
            else
                if effect_data.playerAtTarget then
                    scale = self.effect_custom_scale
                else
                    scale = self.target_effect_custom_scale
                end
                if not scale then
                    scale = Transform.GetLocalScaleOnce(effect.transform)
                end
                if self.effect_size_scale then
                    scale.x = scale.x * self.effect_size_scale.x
                    scale.y = scale.y * self.effect_size_scale.y
                    scale.z = scale.z * self.effect_size_scale.z
                end
            end
            effect.transform.localScale = scale
        end
    end

    --偏移
    if effect_data.isUseCustomTransform then
        local pos = effect.transform.localPosition
        effect.transform.localPosition = Vector3Pool.Get(
                pos.x + effect_data.offsetPosX,
                pos.y + effect_data.offsetPosY,
                pos.z + effect_data.offsetPosZ
        )
    end

    if not effect_data.isAttach and self.effect_custom_rotation then
        effect.transform.localRotation = self.effect_custom_rotation
    end

end

