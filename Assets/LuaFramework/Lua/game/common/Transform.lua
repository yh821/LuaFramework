---
--- Created by Hugo
--- DateTime: 2023/6/10 18:34
---

Transform = {}

function Transform.GetPosition(transform, position)
    if IsNil(transform) then
        return position
    end
    local pos = transform.position
    return pos
end

function Transform.GetPositionOnce(transform)
    local pos = Vector3Pool.Get()
    pos = transform.position
    return pos
end

function Transform.GetForwardOnce(transform)
    local forward = Vector3Pool.Get()
    forward = transform.forward
    return forward
end

function Transform.GetLocalScaleOnce(transform)
    local scale = Vector3Pool.Get()
    scale = transform.localScale
    return scale
end

local mt = {}
mt.__index = function(t, k)
    return UnityEngine.Transform[k]
end

setmetatable(Transform, mt)