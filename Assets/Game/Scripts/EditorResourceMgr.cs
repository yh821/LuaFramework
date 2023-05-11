using System.IO;
using UnityEditor;
using UnityEngine;

public static class EditorResourceMgr
{
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
}