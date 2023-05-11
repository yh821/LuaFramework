using System.Text;
using UnityEditor;
using UnityEngine;

public class AssetImporterMark : AssetPostprocessor
{
	#region Animation

	private void OnPreprocessAnimation()
	{
		Debug.Log("导入动作前");
	}

	private void OnPostprocessAnimation(GameObject root, AnimationClip clip)
	{
		Debug.Log("导入动作:" + root.name);
	}

	#endregion

	#region Assembly

	private void OnPreprocessAssembly(string pathName)
	{
		Debug.Log("导入动态库:" + pathName);
	}

	#endregion

	#region Asset

	private void OnPreprocessAsset()
	{
		// Debug.Log("导入资源前");
	}

	#endregion

	#region Audio

	private void OnPreprocessAudio()
	{
		Debug.Log("导入音频前");
	}

	private void OnPostprocessAudio(AudioClip arg)
	{
		Debug.Log("导入音频:" + arg.name);
	}

	#endregion

	#region Model

	private void OnPreprocessModel()
	{
		Debug.Log("导入模型前");
	}

	private void OnPostprocessModel(GameObject g)
	{
		Debug.Log("导入模型:" + g.name);
	}

	#endregion

	#region Texture

	private void OnPreprocessTexture()
	{
		Debug.Log("导入纹理前");
	}

	private void OnPostprocessTexture(Texture2D texture)
	{
		Debug.Log("导入纹理:" + texture.name);
	}

	private void OnPostprocessSprites(Texture2D texture, Sprite[] sprites)
	{
		var sb = new StringBuilder();
		foreach (var sprite in sprites)
		{
			sb.Append(sprite.name).Append(",\n");
		}

		Debug.Log($"导入精灵 {texture.name}:{{\n{sb}\n}}");
	}

	#endregion

	#region Material

	private void OnPostprocessMaterial(Material material)
	{
		Debug.Log("导入材质球:" + material.name);
	}

	#endregion

	#region AllAssets

	private static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets,
		string[] movedFromAssetPaths)
	{
		if (importedAssets.Length > 0)
		{
			// var sb = new StringBuilder();
			foreach (var imported in importedAssets)
			{
				// sb.Append(importe).Append(",\n");
				AssetBundleImporter.MarkAssetBundle(imported);
			}

			// Debug.Log($"导入资源:{{\n{sb}\n}}");
		}

		// if (deletedAssets.Length > 0)
		// {
		// 	var sb = new StringBuilder();
		// 	foreach (var imported in deletedAssets)
		// 	{
		// 		sb.Append(imported).Append(",\n");
		// 	}
		//
		// 	Debug.Log($"删除资源:{{\n{sb}\n}}");
		// }

		if (movedAssets.Length > 0)
		{
			// var sb = new StringBuilder();
			foreach (var imported in movedAssets)
			{
				// sb.Append(imported).Append(",\n");
				AssetBundleImporter.MarkAssetBundle(imported);
			}

			// Debug.Log($"移动资源到:{{\n{sb}\n}}");
		}

		// if (movedFromAssetPaths.Length > 0)
		// {
		// 	var sb = new StringBuilder();
		// 	foreach (var imported in movedFromAssetPaths)
		// 	{
		// 		sb.Append(imported).Append(",\n");
		// 	}
		//
		// 	Debug.Log($"移动资源来源:{{\n{sb}\n}}");
		// }
	}

	#endregion
}