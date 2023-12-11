using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.EventSystems;

namespace Common
{
	public class SelectionHelper : MonoBehaviour
	{
		private static string mSelectObjPath;
		private static GameObject selectPrefab;

		[InitializeOnLoadMethod]
		public static void OnLoad()
		{
			//Hierarchy面板监听
			EditorApplication.hierarchyWindowItemOnGUI += HierarchyWindowItemOnGUI;
			//Project面板监听
			EditorApplication.projectWindowItemOnGUI += ProjectWindowItemOnGUI;
		}

		private static void HierarchyWindowItemOnGUI(int instanceID, Rect selectionRect)
		{
			var e = Event.current;
			if (e.type == EventType.KeyDown)
			{
				switch (e.keyCode)
				{
					case KeyCode.Space:
						ToggleGameObjectActiveSelf();
						e.Use();
						break;
					// case KeyCode.F1:
					// 	SaveActiveObject();
					// 	e.Use();
					// 	break;
				}
			}
		}

		private static void ProjectWindowItemOnGUI(string guid, Rect selectionRect)
		{
			var e = Event.current;
			if (e.type != EventType.KeyDown || e.keyCode != KeyCode.Space ||
			    !selectionRect.Contains(e.mousePosition)) return;
			var path = AssetDatabase.GUIDToAssetPath(guid);
			if (e.control)
			{
				UnityEngine.Debug.Log(path);
				e.Use();
				return;
			}

			if (Path.GetExtension(path) == string.Empty)
				Process.Start(Path.GetFullPath(path));
			else
				Process.Start("explorer.exe", ".select," + Path.GetFullPath(path));
			e.Use();
		}

		private static void ToggleGameObjectActiveSelf()
		{
			Undo.RecordObjects(Selection.gameObjects, "Active");
			foreach (var gameObject in Selection.gameObjects)
			{
				gameObject.SetActive(!gameObject.activeSelf);
			}
		}

#if UNITY_EDITOR
		private void Update()
		{
			if (Input.GetKey(KeyCode.LeftControl) && Input.GetMouseButtonDown(1))
			{
				var data = new PointerEventData(EventSystem.current);
				data.position = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
				var resultList = new List<RaycastResult>();
				EventSystem.current.RaycastAll(data, resultList);
				if (resultList.Count > 0)
				{
					EditorGUIUtility.PingObject(resultList[0].gameObject);
					Selection.activeGameObject = resultList[0].gameObject;
				}
			}
		}
#endif
	}
}