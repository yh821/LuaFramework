﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class SimpleCameraWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(SimpleCamera), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("MoveToTarget", MoveToTarget);
		L.RegFunction("ChangeAngle", ChangeAngle);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("minAngle", get_minAngle, set_minAngle);
		L.RegVar("maxAngle", get_maxAngle, set_maxAngle);
		L.RegVar("minDistance", get_minDistance, set_minDistance);
		L.RegVar("maxDistance", get_maxDistance, set_maxDistance);
		L.RegVar("angleXSpeed", get_angleXSpeed, set_angleXSpeed);
		L.RegVar("angleYSpeed", get_angleYSpeed, set_angleYSpeed);
		L.RegVar("rotationSensitivity", get_rotationSensitivity, set_rotationSensitivity);
		L.RegVar("distanceSensitivity", get_distanceSensitivity, set_distanceSensitivity);
		L.RegVar("maxTargetBias", get_maxTargetBias, set_maxTargetBias);
		L.RegVar("targetBias", get_targetBias, set_targetBias);
		L.RegVar("targetBiasLeap", get_targetBiasLeap, set_targetBiasLeap);
		L.RegVar("target", get_target, set_target);
		L.RegVar("targetOffset", get_targetOffset, set_targetOffset);
		L.RegVar("StopCameraUpdate", get_StopCameraUpdate, set_StopCameraUpdate);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int MoveToTarget(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			SimpleCamera obj = (SimpleCamera)ToLua.CheckObject<SimpleCamera>(L, 1);
			obj.MoveToTarget();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ChangeAngle(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			SimpleCamera obj = (SimpleCamera)ToLua.CheckObject<SimpleCamera>(L, 1);
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.ChangeAngle(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_minAngle(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float ret = obj.minAngle;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index minAngle on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_maxAngle(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float ret = obj.maxAngle;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maxAngle on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_minDistance(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float ret = obj.minDistance;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index minDistance on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_maxDistance(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float ret = obj.maxDistance;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maxDistance on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_angleXSpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float ret = obj.angleXSpeed;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index angleXSpeed on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_angleYSpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float ret = obj.angleYSpeed;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index angleYSpeed on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_rotationSensitivity(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float ret = obj.rotationSensitivity;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index rotationSensitivity on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_distanceSensitivity(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float ret = obj.distanceSensitivity;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index distanceSensitivity on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_maxTargetBias(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float ret = obj.maxTargetBias;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maxTargetBias on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_targetBias(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float ret = obj.targetBias;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index targetBias on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_targetBiasLeap(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float ret = obj.targetBiasLeap;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index targetBiasLeap on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_target(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			UnityEngine.Transform ret = obj.target;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index target on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_targetOffset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			UnityEngine.Vector3 ret = obj.targetOffset;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index targetOffset on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_StopCameraUpdate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			bool ret = obj.StopCameraUpdate;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index StopCameraUpdate on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_minAngle(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.minAngle = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index minAngle on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_maxAngle(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.maxAngle = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maxAngle on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_minDistance(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.minDistance = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index minDistance on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_maxDistance(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.maxDistance = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maxDistance on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_angleXSpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.angleXSpeed = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index angleXSpeed on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_angleYSpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.angleYSpeed = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index angleYSpeed on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_rotationSensitivity(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.rotationSensitivity = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index rotationSensitivity on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_distanceSensitivity(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.distanceSensitivity = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index distanceSensitivity on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_maxTargetBias(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.maxTargetBias = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index maxTargetBias on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_targetBias(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.targetBias = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index targetBias on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_targetBiasLeap(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.targetBiasLeap = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index targetBiasLeap on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_target(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 2);
			obj.target = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index target on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_targetOffset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.targetOffset = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index targetOffset on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_StopCameraUpdate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			SimpleCamera obj = (SimpleCamera)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.StopCameraUpdate = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index StopCameraUpdate on a nil value");
		}
	}
}

