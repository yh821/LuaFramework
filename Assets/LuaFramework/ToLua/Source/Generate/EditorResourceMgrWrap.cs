﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class EditorResourceMgrWrap
{
	public static void Register(LuaState L)
	{
		L.BeginStaticLibs("EditorResourceMgr");
		L.RegFunction("IsExitsAsset", IsExitsAsset);
		L.RegFunction("LoadGameObject", LoadGameObject);
		L.EndStaticLibs();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsExitsAsset(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			bool o = EditorResourceMgr.IsExitsAsset(arg0, arg1);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadGameObject(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			UnityEngine.GameObject o = EditorResourceMgr.LoadGameObject(arg0, arg1);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}
