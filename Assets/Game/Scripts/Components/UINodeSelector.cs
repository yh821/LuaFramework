#if UNITY_EDITOR

using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.EventSystems;

public class UINodeSelector : MonoBehaviour
{
	private void Update()
	{
		if (Input.GetKey(KeyCode.LeftControl) && Input.GetMouseButton(1))
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
}

#endif