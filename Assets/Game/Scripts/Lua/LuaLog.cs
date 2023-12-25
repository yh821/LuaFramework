using System;
using LuaInterface;

public static class LuaLog
{
#if UNITY_EDITOR || UNITY_STANDALONE
	public static bool printTraceBack = true;
#else
    public static bool printTraceBack = false;
#endif
	public static void OpenLibs(LuaState state)
	{
		state.LuaPushFunction(PrintLog);
		state.LuaSetGlobal("print_log");
		state.LuaPushFunction(PrintWarning);
		state.LuaSetGlobal("print_warning");
		state.LuaPushFunction(PrintError);
		state.LuaSetGlobal("print_error");
	}

	[MonoPInvokeCallback(typeof(LuaCSFunction))]
	private static int PrintLog(IntPtr l)
	{
		try
		{
			var output = FormatPrint(l);
			Debugger.Log(output);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(l, e);
		}
	}

	[MonoPInvokeCallback(typeof(LuaCSFunction))]
	private static int PrintWarning(IntPtr l)
	{
		try
		{
			var output = FormatPrint(l);
			Debugger.LogWarning(output);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(l, e);
		}
	}

	[MonoPInvokeCallback(typeof(LuaCSFunction))]
	private static int PrintError(IntPtr l)
	{
		try
		{
			var output = FormatPrint(l);
			Debugger.LogError(output);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(l, e);
		}
	}

	private static string FormatPrint(IntPtr l)
	{
		var n = LuaDLL.lua_gettop(l);
		var sb = StringBuilderCache.Acquire();
		if (printTraceBack)
		{
			var line = LuaDLL.tolua_where(l, 1);
			var fileName = LuaDLL.lua_tostring(l, -1);
			LuaDLL.lua_settop(l, n);
			sb.AppendFormat(fileName.Contains(".") ? "[{0}:{1}]:" : "[{0}.lua:{1}]:", fileName, line);
		}

		for (int i = 1; i <= n; i++)
		{
			if (i > 1) sb.Append("  ");
			var text = PrintVariable(l, i, 0);
			sb.Append(text);
		}

		if (printTraceBack)
			sb.AppendFormat("\n{0}\n", GetStackTrace(l));

		return StringBuilderCache.GetStringAndRelease(sb);
	}

	private static string PrintVariable(IntPtr l, int i, int depth)
	{
		if (LuaDLL.lua_isstring(l, i) == 1)
			return LuaDLL.lua_tostring(l, i);
		if (LuaDLL.lua_isboolean(l, i))
			return LuaDLL.lua_toboolean(l, i) ? "true" : "false";
		if (LuaDLL.lua_isnil(l, i))
			return "nil";
		if (LuaDLL.lua_istable(l, i))
		{
			if (depth > 3) return "{...}";
			var sb = StringBuilderCache.Acquire();
			sb.Append("{");
			var count = 0;
			LuaDLL.lua_pushvalue(l, i);
			LuaDLL.lua_pushnil(l);
			while (LuaDLL.lua_next(l, i) != 0)
			{
				LuaDLL.lua_pushvalue(l, -2);
				var key = PrintVariable(l, -1, depth + 1);
				var value = PrintVariable(l, -2, depth + 1);
				if (count == 0)
					sb.AppendFormat("{0} = {1}", key, value);
				else
					sb.AppendFormat(", {0} = {1}", key, value);
				LuaDLL.lua_pop(l, 2);
				count++;
			}

			LuaDLL.lua_pop(l, 1);
			sb.Append("}");
			return StringBuilderCache.GetStringAndRelease(sb);
		}

		var p = LuaDLL.lua_topointer(l, i);
		return p == IntPtr.Zero ? "nil" : $"{LuaDLL.luaL_typename(l, i)}:0x{p.ToString("X")}";
	}

	private static string GetStackTrace(IntPtr l)
	{
		LuaDLL.lua_getglobal(l, "debug");
		LuaDLL.lua_getfield(l, -1, "traceback");
		LuaDLL.lua_pcall(l, 0, 1, 0);
		return LuaDLL.lua_tostring(l, -1);
	}
}