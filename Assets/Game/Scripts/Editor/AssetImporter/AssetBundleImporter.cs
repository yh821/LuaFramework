using System;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;

public static class AssetBundleImporter
{
	public const string BaseDir = "Assets/Game";
	public const string SceneDir = BaseDir + "/Scenes";
	public const string ViewDir = BaseDir + "/Views";
	public const string AudioDir = BaseDir + "/Audios";
	public const string EnvironmentsDir = BaseDir + "/Environments";

	public const string ActorDir = BaseDir + "/Actors";
	public const string RoleDir = ActorDir + "/Role";
	public const string MonsterDir = ActorDir + "/Monster";
	public const string PetDir = ActorDir + "/Pet";

	private static readonly Regex LogicRegex = new Regex(@".+logic\d+\.unity");

	private static readonly char[] Seperator =
	{
		'/', '\\'
	};

	public static void MarkAssetBundle(string asset)
	{
		if (!asset.StartsWith(BaseDir)) return;
		var ext = Path.GetExtension(asset);
		if (".cs".Equals(ext, StringComparison.OrdinalIgnoreCase)) return;

		var importer = AssetImporter.GetAtPath(asset);
		if (!importer) return;

		var bundleName = GetAssetBundleName(asset);
		bundleName = FixAssetBundleName(bundleName);
		if (!string.Equals(importer.assetBundleName, bundleName))
		{
			importer.assetBundleName = bundleName;
			importer.SaveAndReimport();
		}
	}

	private static string FixAssetBundleName(string bundleName)
	{
		bundleName = bundleName.Replace(" ", "");
		bundleName = bundleName.Replace("—", "-");
		bundleName = Regex.Replace(bundleName, "[\u4E00-\u9FA5]+", "");

		return bundleName;
	}

	private static string GetAssetBundleName(string asset)
	{
		if (!IsNeedMark(asset)) return string.Empty;
		var bundleName = string.Empty;
		if (string.IsNullOrEmpty(bundleName)) bundleName = TryGetPrefabName(asset);
		if (string.IsNullOrEmpty(bundleName)) bundleName = TryGetSceneName(asset);
		if (string.IsNullOrEmpty(bundleName)) bundleName = TryGetAudioName(asset);
		return bundleName.ToLower();
	}

	private static string TryGetAudioName(string asset)
	{
		if (asset.StartsWith(AudioDir) && Path.GetDirectoryName(asset) != AudioDir)
			return GetRelativeDirPath(asset, BaseDir);
		return string.Empty;
	}

	private static string TryGetSceneName(string asset)
	{
		asset = asset.ToLower();
		if (asset.EndsWith(".unity") && !LogicRegex.IsMatch(asset))
		{
			var bundleName = GetRelativeDirPath(asset, BaseDir);
			var sceneMark = Regex.Replace(Path.GetFileNameWithoutExtension(asset), ".+_", "_");
			return bundleName + sceneMark;
		}

		return string.Empty;
	}

	private static string TryGetPrefabName(string asset)
	{
		if (asset.EndsWith(".prefab"))
		{
			if (asset.StartsWith(RoleDir)) return GetActorBundleName("role", asset);
			if (asset.StartsWith(PetDir)) return GetActorBundleName("pet", asset);
			if (asset.StartsWith(MonsterDir)) return GetActorBundleName("monster", asset);
			if (asset.StartsWith(ActorDir)) return GetAssetBundleName("actors", asset);
			if (asset.StartsWith(ViewDir)) return GetAssetBundleName("views", asset);
			if (!asset.StartsWith(EnvironmentsDir)) return GetRelativeDirPath(asset, BaseDir) + "_prefab";
		}

		return string.Empty;
	}

	private static string GetAssetBundleName(string dir, string asset)
	{
		var paths = asset.Split(Seperator);
		var parentDir = paths[paths.Length - 2];
		if (string.CompareOrdinal(parentDir, dir) != 0)
			return $"{dir}/{parentDir}_prefab";
		return GetRelativeDirPath(asset, BaseDir);
	}

	private static string GetActorBundleName(string dir, string asset)
	{
		var paths = asset.Split(Seperator);
		var parentDir = paths[paths.Length - 2];
		if (string.CompareOrdinal(parentDir, dir) != 0)
			return $"actors/{dir}/{parentDir}_prefab";
		return GetRelativeDirPath(asset, BaseDir);
	}

	private static string GetViewBundleName(string dir, string asset)
	{
		var paths = asset.Split(Seperator);
		var parentDir = paths[paths.Length - 2];
		if (string.CompareOrdinal(parentDir, dir) != 0)
			return $"views/{dir}/{parentDir}_prefab";
		return GetRelativeDirPath(asset, BaseDir);
	}

	private static string GetRelativeDirPath(string path, string basePath)
	{
		basePath = basePath.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
		var relativePath = path.Substring(basePath.Length + 1);
		return Path.GetDirectoryName(relativePath)?.ToLower().Replace("\\", "/");
	}

	private static bool IsNeedMark(string asset)
	{
		if (AssetDatabase.IsValidFolder(asset)) return false;
		if (asset.Contains("/Editor/") || asset.Contains("/editor/")) return false;
		return true;
	}
}