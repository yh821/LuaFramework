---
--- Created by Hugo
--- DateTime: 2023/6/10 16:57
---

---@class ActorCtrl
ActorCtrl = ActorCtrl or BaseClass()

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
end

function ActorCtrl:SetEffectSpeed(speed)
end

function ActorCtrl:SetPrefabData(data)
    self.prefab_data = data
end

function ActorCtrl:GetPrefabData()
    return self.prefab_data
end

function ActorCtrl:PlayProjectile(main_part_obj, action, root, hurt_point, callback, cb_data, offset_pos, key)

end

local function DelayPlayProjectile(cb_data)

end

function ActorCtrl:PlayProjectileImpl(main_part_obj, projectile, root, hurt_point, callback, cb_data, offset_pos, key)

end

local function LoadProjectileCallBack(obj, cb_data)

end

function ActorCtrl:RemoveOnPlayProjectileWithEffects(token)

end

function ActorCtrl:SetOnPlayProjectileWithEffect(callback)

end

function ActorCtrl:LoadByExternal(bundle, asset, cb_data)
    local loader = cb_data[1]
    loader:Load(bundle, asset, LoadProjectileCallBack, cb_data)
end

function ActorCtrl:PlayProjectileWithEffect(main_part_obj, projectile, hurt_point, from_pos, callback, cb_data, key)

end

local function DelayPlayProjectileWithoutEffect(cb_data)

end

function ActorCtrl:PlayProjectileWithoutEffect(callback, cb_data)

end

function ActorCtrl:PlayHurtShow(skill_action, root, hurt_point, callback, cb_data)

end

function ActorCtrl:PlayHurtEffect(data, root, hurt_point)

end

function ActorCtrl:PlayHitEffect(data, root, hurt_point, callback, cb_data)
end

function ActorCtrl:PlayHurt(skill_action, per_hit, cb_data)
end

function ActorCtrl:PlayHit(hurts, per_hit, cb_data)
end

function ActorCtrl:PlayBeHurt(root)
end

function ActorCtrl:PlayBeHitEffect(bundle, asset, root, position, attached)
end

function ActorCtrl:PlaySound(data)
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

ActorCtrl.cb_data_list = {}
function ActorCtrl.GetCbData()
    local data = table.remove(ActorCtrl.cb_data_list)
    if data == nil then
        data = { true, true, true, true, true, true, true, true }
    end
    return data
end

function ActorCtrl.ReleaseCbData(cb_data)
    cb_data[1] = true
    cb_data[2] = true
    cb_data[3] = true
    cb_data[4] = true
    cb_data[5] = true
    cb_data[6] = true
    cb_data[7] = true
    cb_data[8] = true
    table.insert(ActorCtrl.cb_data_list, cb_data)
end