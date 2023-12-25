using System;
using System.IO;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

namespace Game
{
	[Serializable]
	public struct AssetID : IEquatable<AssetID>
	{
		public static readonly AssetID Empty = new AssetID(string.Empty, string.Empty);
		[SerializeField] private string bundleName;
		[SerializeField] private string assetName;
		[SerializeField] private string assetGUID;

		public AssetID(string bundleName, string assetName)
		{
			this.bundleName = bundleName;
			this.assetName = assetName;
			this.assetGUID = string.Empty;
		}

		public string BundleName
		{
			get => bundleName;
			set => bundleName = value;
		}

		public string AssetName
		{
			get => assetName;
			set => assetName = value;
		}

		public string AssetGuid
		{
			get => assetGUID;
			set => assetGUID = value;
		}

		public bool IsEmpty => string.IsNullOrEmpty(BundleName) || string.IsNullOrEmpty(AssetName);

		public static AssetID Pares(string text)
		{
			if (string.IsNullOrEmpty(text))
				return new AssetID();
			var length = text.IndexOf(':');
			if (length > 0)
				return new AssetID(text.Substring(0, length), text.Substring(length + 1));
			throw new FormatException("Can not pares AssetID.");
		}

#if UNITY_EDITOR
		public string GetAssetPath()
		{
			if (IsEmpty)
				return null;
			string str = null;
			if (!string.IsNullOrEmpty(assetGUID))
				str = AssetDatabase.GUIDToAssetPath(assetGUID);
			if (string.IsNullOrEmpty(str))
			{
				var bundleAndAssetName =
					AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundleName,
						Path.GetFileNameWithoutExtension(assetName));
				if (Path.HasExtension(assetName))
				{
					var extension = Path.GetExtension((assetName));
					foreach (var path in bundleAndAssetName)
					{
						if (Path.GetExtension(path) == extension)
						{
							str = path;
							break;
						}
					}
				}
				else if ((uint) bundleAndAssetName.Length > 0U)
					str = bundleAndAssetName[0];
			}

			return str;
		}

		public T LoadObject<T>() where T : UnityEngine.Object
		{
			var assetPath = GetAssetPath();
			return string.IsNullOrEmpty(assetPath) ? default : AssetDatabase.LoadAssetAtPath<T>(assetPath);
		}

		public void RefreshAssetBundleName()
		{
			var assetPath = AssetDatabase.GUIDToAssetPath(assetGUID);
			var atPath = AssetImporter.GetAtPath(assetPath);
			if (atPath == null) return;
			bundleName = atPath.assetBundleName;
			assetName = assetPath.Substring(assetPath.LastIndexOf('/') + 1);
		}
#endif
		public bool Equals(AssetID other)
		{
			return BundleName == other.BundleName && AssetName == other.AssetName;
		}

		public override string ToString()
		{
			return bundleName + ":" + assetName;
		}

		public override int GetHashCode()
		{
			return 397 * bundleName.GetHashCode() ^ assetName.GetHashCode();
		}
	}
}