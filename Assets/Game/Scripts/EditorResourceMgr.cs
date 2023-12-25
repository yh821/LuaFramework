using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using LuaInterface;
using UnityEditor;
#if UNITY_EDITOR
using UnityEditor.SceneManagement;
#endif
using UnityEngine;
using UnityEngine.SceneManagement;
using UObject = UnityEngine.Object;

public static class EditorResourceMgr
{
#if UNITY_EDITOR
	private static Dictionary<GameObject, int> _originalInstanceIdMap = new Dictionary<GameObject, int>();
	private static Dictionary<UObject, string> _assetPathMap = new Dictionary<UObject, string>();
	[NoToLua] public static Action<string, string> LoadAction;
#endif

	public static bool IsExitsAsset(string bundleName, string assetName)
	{
#if UNITY_EDITOR
		assetName = Path.GetFileNameWithoutExtension(assetName);
		var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundleName, assetName);
		return assetPaths.Length > 0;
#else
		return false;
#endif
	}

	public static GameObject LoadGameObject(string bundleName, string assetName)
	{
#if UNITY_EDITOR
		assetName = Path.GetFileNameWithoutExtension(assetName);
		var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundleName, assetName);
		if (assetPaths.Length > 0)
		{
			var assetPath = assetPaths[0];
			return AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
		}
#endif
		return null;
	}

	public static UObject LoadObject(string bundleName, string assetName, Type type)
	{
#if UNITY_EDITOR
		LoadAction?.Invoke(bundleName, assetName);

		var realSuffix = Path.GetExtension(assetName);
		assetName = Path.GetFileNameWithoutExtension(assetName);
		var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundleName, assetName);
		if (assetPaths.Length > 0)
		{
			var assetPath = assetPaths[0];
			if (!string.IsNullOrEmpty(realSuffix))
			{
				var suffix = Path.GetExtension(assetPath);
				if (!string.IsNullOrEmpty(suffix))
					assetPath = assetPath.Replace(suffix, realSuffix);
			}

			return AssetDatabase.LoadAssetAtPath(assetPath, type);
		}
#endif
		return null;
	}

	public static bool LoadLevelSync(string bundleName, string assetName, LoadSceneMode loadSceneMode)
	{
#if UNITY_EDITOR
		LoadAction?.Invoke(bundleName, assetName);
		assetName = Path.GetFileNameWithoutExtension(assetName);
		var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundleName, assetName);
		if (assetPaths.Length > 0)
		{
			var assetPath = assetPaths[0];
			EditorSceneManager.LoadSceneInPlayMode(assetPath, new LoadSceneParameters(loadSceneMode));
			return true;
		}
#endif
		return false;
	}

	public static bool LoadLevelAsync(string bundleName, string assetName, LoadSceneMode loadSceneMode)
	{
#if UNITY_EDITOR
		LoadAction?.Invoke(bundleName, assetName);
		assetName = Path.GetFileNameWithoutExtension(assetName);
		var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundleName, assetName);
		if (assetPaths.Length > 0)
		{
			var assetPath = assetPaths[0];
			EditorSceneManager.LoadSceneAsyncInPlayMode(assetPath, new LoadSceneParameters(loadSceneMode));
			return true;
		}
#endif
		return false;
	}

	public static void CacheOriginalInstanceMapping(GameObject go, GameObject prefab)
	{
#if UNITY_EDITOR
		if (prefab != null)
		{
			_originalInstanceIdMap.Add(go, prefab.GetInstanceID());
			_assetPathMap.Add(go, AssetDatabase.GetAssetPath(prefab.GetInstanceID()));
		}
#endif
	}

	public static void SweepOriginalInstanceIdMap()
	{
#if UNITY_EDITOR
		_originalInstanceIdMap.RemoveAll((gameObj, originalInstanceId) => gameObj == null);
		_assetPathMap.RemoveAll((obj, originalInstanceId) => obj == null);
#endif
	}

	public static int GetOriginalInstanceId(GameObject go)
	{
#if UNITY_EDITOR
		if (go == null) return 0;
		return !_originalInstanceIdMap.TryGetValue(go, out var originalInstanceId) ? 0 : originalInstanceId;
#else
		return 0;
#endif
	}

	public static string GetAssetPath(UObject obj)
	{
#if UNITY_EDITOR
		if (obj == null) return string.Empty;
		return !_assetPathMap.TryGetValue(obj, out var path) ? string.Empty : path;
#else
		return string.Empty;
#endif
	}

	public static void OutputAssetPathMap()
	{
#if UNITY_EDITOR
		_assetPathMap.RemoveAll((obj, originalInstanceId) => obj == null);
		var path = $"{Application.dataPath}/../temp/asset_path_map.txt";
		File.WriteAllLines(path, _assetPathMap.Values.ToArray());
		Debug.LogFormat("保存路径：{0}", path);
#endif
	}

	public static bool IsCanLoadAssetInGameObj(GameObject go, string bundleName, string assetName)
	{
#if UNITY_EDITOR
		var canvases = go.GetComponentsInChildren<Canvas>();
		var assetPath = string.Empty;
		foreach (var canvas in canvases)
		{
			assetPath = GetAssetPath(canvas.gameObject);
			if (!string.IsNullOrEmpty(assetPath)) break;
		}

		if (string.IsNullOrEmpty(assetPath)) return true;

		var inBundleName = AssetDatabase.GetImplicitAssetBundleName(assetPath);
		if (string.IsNullOrEmpty(inBundleName)) return true;

		if (!inBundleName.StartsWith("uis/views/") || !bundleName.StartsWith("uis/views/")) return true;

		var fixInBundleName = inBundleName;
		fixInBundleName = fixInBundleName.Replace("uis/views/", "");
		if (fixInBundleName.IndexOf('/') >= 0)
			fixInBundleName = fixInBundleName.Substring(0, fixInBundleName.IndexOf('/'));
		fixInBundleName = fixInBundleName.Replace("_prefab", "");

		var fixBundleName = bundleName;
		fixBundleName = fixBundleName.Replace("uis/views/", "");
		if (fixBundleName.IndexOf('/') >= 0)
			fixBundleName = fixBundleName.Substring(0, fixBundleName.IndexOf('/'));

		if (fixBundleName == "mainui") return true;

		if (fixInBundleName == "commonwidgets" || fixInBundleName == "miscpreload") return true;

		if (fixInBundleName == fixBundleName) return true;

		var parent = go.transform.parent;
		var nodePath = go.name;
		while (parent)
		{
			nodePath = parent.name + "/" + nodePath;
			parent = parent.transform.parent;
			if (parent.name == "UILayer") break;
		}

		Debug.LogError($"禁止加载其他模块的资源，你尝试在{inBundleName}模块下加载{bundleName}:{assetName}");
		Debug.Log(nodePath);

		return false;
#else
		return true;
#endif
	}
}