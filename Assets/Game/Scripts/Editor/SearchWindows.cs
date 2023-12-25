using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class SearchWindows : EditorWindow
{
	[MenuItem("Assets/Search Reference")]
	public static void OpenWindow()
	{
		((SearchWindows) GetWindow(typeof(SearchWindows))).search = Selection.activeObject;
	}

	public Object search;
	private readonly List<Object> _searchOut = new List<Object>();

	private void OnGUI()
	{
		EditorGUILayout.BeginHorizontal();
		GUILayout.Label("Search:", EditorStyles.boldLabel);
		search = EditorGUILayout.ObjectField(search, typeof(Object), true);
		EditorGUILayout.EndHorizontal();

		if (GUILayout.Button("Search!"))
		{
			if (search != null)
			{
				_searchOut.Clear();
				var path = AssetDatabase.GetAssetPath(search);
				if (!string.IsNullOrEmpty(path))
				{
					var guid = AssetDatabase.AssetPathToGUID(path);
					var meta = AssetDatabase.GetTextMetaFilePathFromAssetPath(path);
					var p = new System.Diagnostics.Process();
					p.StartInfo.WorkingDirectory = Application.dataPath;
					p.StartInfo.FileName = $"{Application.dataPath}/../Tools/Search/rg.exe";
					p.StartInfo.Arguments = $"-l {guid}";
					p.StartInfo.UseShellExecute = false;
					p.StartInfo.RedirectStandardOutput = true;
					p.StartInfo.CreateNoWindow = true;
					p.Start();
					while (!p.StandardOutput.EndOfStream)
					{
						var line = $"Assets/{p.StandardOutput.ReadLine().Replace("\\", "/")}";
						if (line == meta) continue;
						var item = AssetDatabase.LoadAssetAtPath(line, typeof(Object));
						if (item != null)
							_searchOut.Add(item);
					}
				}
			}
		}

		if (_searchOut.Count > 0)
		{
			GUILayout.Label("Out:", EditorStyles.boldLabel);
			foreach (var o in _searchOut)
			{
				EditorGUILayout.ObjectField(o, typeof(Object), true);
			}
		}
	}
}