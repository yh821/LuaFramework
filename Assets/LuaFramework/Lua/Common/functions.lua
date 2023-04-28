
--输出日志--
function print_log(msg)
    Util.Log(msg .. "\n" .. debug.traceback());
end

--错误日志--
function print_error(msg)
	Util.LogError(msg);
end

--警告日志--
function print_warning(msg)
	Util.LogWarning(msg .. "\n" .. debug.traceback());
end

--查找对象--
function Find(str)
	return GameObject.Find(str);
end

function Destroy(obj)
	GameObject.Destroy(obj);
end

function Instantiate(prefab)
	return GameObject.Instantiate(prefab);
end

--创建面板--
function CreatePanel(name)
	PanelManager:CreatePanel(name);
end

function FindChild(str)
	return transform:FindChild(str);
end

function subGet(childNode, typeName)
	return FindChild(childNode):GetComponent(typeName);
end

function FindPanel(str)
	local obj = Find(str);
	if obj == nil then
		error(str.." is null");
		return nil;
	end
	return obj:GetComponent("BaseLua");
end