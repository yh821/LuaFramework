using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;
using UnityEngine.Assertions;

namespace Game
{
	[CustomEditor(typeof(UINameTable))]
	internal sealed class UINameTableEditor : Editor
	{
		private static GameObject searchNameTableObj = null;
		private static GameObject searchObject = null;
		private HashSet<int> duplicateIndexs = new HashSet<int>();
		Dictionary<string, int> checkTable = new Dictionary<string, int>(StringComparer.Ordinal);
		Dictionary<UnityEngine.Object, int> checkGoDuplicateTable = new Dictionary<UnityEngine.Object, int>();
		private GameObject newObject = null;
		private UnityEngine.Object duplicateObject = null;
		private SerializedProperty binds;
		private ReorderableList bindList;
		private string searchText;
		private UINameTable.BindPair[] searchResult;

		public override void OnInspectorGUI()
		{
			serializedObject.Update();
			bindList.DoLayoutList();
			if (serializedObject.ApplyModifiedProperties())
				FindDuplicate();
			UINameTable target = (UINameTable) this.target;
			GUILayout.BeginHorizontal();
			{
				newObject = EditorGUILayout.ObjectField(newObject, typeof(GameObject), true) as GameObject;
				if (GUILayout.Button("Add"))
				{
					if (newObject == null) return;
					duplicateObject = null;
					if (FindDuplicate(newObject))
					{
						Debug.LogError("duplicated object");
						return;
					}

					var name = newObject.name;
					var num = 0;
					while (true)
					{
						if (target.Find(name))
						{
							name += num.ToString();
							num++;
						}
						else
							break;
					}

					Undo.RecordObject(target, "Add To Name Table");
					serializedObject.Update();
					target.Add(name, newObject);
					serializedObject.ApplyModifiedProperties();
				}
			}
			GUILayout.EndHorizontal();
			var str = EditorGUILayout.TextField("Search:", searchText);
			if (string.IsNullOrEmpty(str))
			{
				searchText = null;
				searchResult = null;
			}
			else if (str != searchText)
			{
				searchText = str;
				searchResult = target.Search(searchText);
			}

			if (searchResult != null)
			{
				GUI.enabled = false;
				GUILayout.BeginVertical(GUI.skin.textArea);
				{
					foreach (var pair in searchResult)
					{
						EditorGUILayout.BeginHorizontal();
						EditorGUILayout.LabelField(pair.Name);
						EditorGUILayout.ObjectField(pair.Widget, pair.Widget.GetType(), true);
						EditorGUILayout.EndHorizontal();
					}
				}
				GUILayout.EndVertical();
				GUI.enabled = true;
			}

			if (!GUILayout.Button("Sort")) return;
			Undo.RecordObject(target, "Sort Name Table");
			serializedObject.Update();
			target.Sort();
			serializedObject.ApplyModifiedProperties();
		}

		private void OnDisable()
		{
			UINameTable target = (UINameTable) this.target;
			if (target == null || target.gameObject != searchNameTableObj)
				return;
			searchNameTableObj = null;
			searchObject = null;
		}

		private void OnEnable()
		{
			if (target == null) return;
			binds = serializedObject.FindProperty("binds");
			bindList = new ReorderableList(serializedObject, binds);
			bindList.drawHeaderCallback = rect => DrawBindHeader(rect);
			bindList.elementHeight = EditorGUIUtility.singleLineHeight;
			bindList.drawElementCallback =
				(rect, index, selected, focused) => DrawBind(binds, rect, index, selected, focused);
		}

		private void DrawBind(SerializedProperty property, Rect rect, int index, bool selected, bool focused)
		{
			var arrayElementAtIndex = property.GetArrayElementAtIndex(index);
			var flag = duplicateIndexs.Contains(index);
			var color = GUI.color;
			if (flag) GUI.color = Color.magenta;
			var property1 = arrayElementAtIndex.FindPropertyRelative("Name");
			var property2 = arrayElementAtIndex.FindPropertyRelative("Widget");
			if (property2.objectReferenceValue == duplicateObject)
				GUI.color = Color.cyan;
			else if (property2.objectReferenceValue == newObject || property2.objectReferenceValue == searchObject)
				GUI.color = Color.green;
			var pos1 = new Rect(rect.x, rect.y, rect.width / 2f - 5f, EditorGUIUtility.singleLineHeight);
			var pos2 = new Rect(rect.x + rect.width / 2f + 5f, rect.y, rect.width / 2f - 5f,
				EditorGUIUtility.singleLineHeight);
			EditorGUI.PropertyField(pos1, property1, GUIContent.none);
			EditorGUI.PropertyField(pos2, property2, GUIContent.none);
			GUI.color = color;
		}

		private void DrawBindHeader(Rect rect)
		{
			var pos1 = new Rect(rect.x + 13f, rect.y, rect.width / 2f, EditorGUIUtility.singleLineHeight);
			var pos2 = new Rect(rect.x + 10f + rect.width / 2f, rect.y, rect.width / 2f,
				EditorGUIUtility.singleLineHeight);
			GUI.Label(pos1, "Name");
			GUI.Label(pos2, "Widget");
		}

		private bool FindDuplicate(UnityEngine.Object go)
		{
			for (int i = 0; i < binds.arraySize; i++)
			{
				if (binds.GetArrayElementAtIndex(i).FindPropertyRelative("Widget").objectReferenceValue == go)
				{
					duplicateObject = go;
					return true;
				}
			}

			return false;
		}

		private void FindDuplicate()
		{
			duplicateIndexs.Clear();
			checkTable.Clear();
			checkGoDuplicateTable.Clear();
			for (int i = 0; i < binds.arraySize; i++)
			{
				var arrayElementAtIndex = binds.GetArrayElementAtIndex(i);
				var propertyRelative = arrayElementAtIndex.FindPropertyRelative("Name");
				var objectReferenceValue = arrayElementAtIndex.FindPropertyRelative("Widget").objectReferenceValue;
				if (checkTable.ContainsKey(propertyRelative.stringValue))
				{
					duplicateIndexs.Add(checkTable[propertyRelative.stringValue]);
					duplicateIndexs.Add(i);
				}
				else if (objectReferenceValue != null && checkGoDuplicateTable.ContainsKey(objectReferenceValue))
				{
					duplicateIndexs.Add(checkGoDuplicateTable[objectReferenceValue]);
					duplicateIndexs.Add(i);
				}
				else
				{
					checkTable.Add(propertyRelative.stringValue, i);
					if (objectReferenceValue != null)
						checkGoDuplicateTable.Add(objectReferenceValue, i);
				}
			}
		}

		[MenuItem("GameObject/Find Name Table #f", priority = 0)]
		private static void FindNameTable()
		{
			var go = Selection.activeGameObject;
			if (go == null) return;
			var components = go.transform.GetComponentsInParent<UINameTable>(true);
			if (components.Length <= 0) return;
			foreach (var componentsInChild in components[components.Length - 1]
				.GetComponentsInChildren<UINameTable>(true))
			{
				foreach (var bind in componentsInChild.binds)
				{
					if (go == bind.Widget)
					{
						Selection.activeObject = componentsInChild.gameObject;
						searchNameTableObj = Selection.activeObject as GameObject;
						searchObject = go;
						break;
					}
				}
			}
		}

		[MenuItem("GameObject/Add Name Table #t", priority = 0)]
		private static void AddNameTable()
		{
			var go = Selection.activeGameObject;
			var component = SearchNameTable(go.transform);
			if (component.binds.Any(bind => bind.Name == go.name))
			{
				Debug.LogError("发现同名key:" + go.name);
				return;
			}

			var item = default(UINameTable.BindPair);
			item.Name = go.name;
			item.Widget = go;
			component.binds.Add(item);
			EditorUtility.SetDirty(component);
			AssetDatabase.Refresh();
		}

		private static UINameTable SearchNameTable(Transform trans)
		{
			Assert.IsNotNull(trans, "没有找到UINameTable");
			var component = trans.GetComponent<UINameTable>();
			return component == null ? SearchNameTable(trans.parent) : component;
		}
	}
}