
CtrlNames = {
	Runner = "Runner",
	Prompt = "PromptCtrl",
	Message = "MessageCtrl",
	AiManager = "AiManager",
}

--协议类型--
ProtocalType = {
	BINARY = 0,
	PB_LUA = 1,
	PBC = 2,
	SPROTO = 3,
}
--当前使用的协议类型--
TestProtoType = ProtocalType.BINARY;

Util = LuaFramework.Util;
AppConst = LuaFramework.AppConst;
LuaHelper = LuaFramework.LuaHelper;
ByteBuffer = LuaFramework.ByteBuffer;

ResourceManager = LuaHelper.GetResManager();
PanelManager = LuaHelper.GetPanelManager();
SoundManager = LuaHelper.GetSoundManager();
NetworkManager = LuaHelper.GetNetManager();

WWW = UnityEngine.WWW;
GameObject = UnityEngine.GameObject;