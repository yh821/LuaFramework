using System;
using System.Collections.Generic;
using UnityEngine;

public class GravitySensor : MonoBehaviour
{
	[Serializable]
	public struct Node
	{
		public Transform rect;
		public Vector2 range;
		[NonSerialized] public Vector3 pos;
		[NonSerialized] public Vector2 min;
		[NonSerialized] public Vector2 max;
	}

	public RectTransform zoom;
	public Transform ball;
	[Range(0, 6)] public float speed = 2;
	[SerializeField] public List<Node> nodeList;

#if UNITY_EDITOR || UNITY_STANDALONE_WIN
	private Vector3 center;
	private Vector3 direction;
#else
	private Vector2 center;
#endif
	private Vector3 lastAcc;

	private void Start()
	{
		InitNodeList();
#if UNITY_EDITOR || UNITY_STANDALONE_WIN
		center = new Vector3(Screen.width / 2f, Screen.height / 2f);
#else
		lastAcc = Input.acceleration;
		center = zoom.rect.size / 2f;
		ball.localPosition = Vector3.zero;
#endif
	}

	private void Update()
	{
		if (nodeList == null) return;
#if UNITY_EDITOR || UNITY_STANDALONE_WIN
		direction = Input.mousePosition - center;
		var acc = new Vector3(Mathf.Clamp(direction.x / center.x, -1, 1),
			Mathf.Clamp(direction.y / center.y, -1, 1));
#else
		var acc = Input.acceleration;
#endif
		lastAcc = Vector3.Lerp(lastAcc, acc.x * acc.x + acc.y * acc.y < 0.001f ? Vector3.zero : acc,
			Time.deltaTime * speed);
		foreach (var node in nodeList)
		{
			node.rect.localPosition = GetPos(node, lastAcc);
		}

		var dir = lastAcc * 50;
		var pos = ball.localPosition + dir;
		pos.x = Mathf.Clamp(pos.x, -center.x, center.x);
		pos.y = Mathf.Clamp(pos.y, -center.y, center.y);
		pos.z = 0;
		ball.localPosition = pos;
	}

	void InitNodeList()
	{
		for (int i = 0; i < nodeList.Count; i++)
		{
			var item = nodeList[i];
			item.pos = item.rect.localPosition;
			item.min = new Vector2(item.pos.x - item.range.x, item.pos.y - item.range.y);
			item.max = new Vector2(item.pos.x + item.range.x, item.pos.y + item.range.y);
			nodeList[i] = item;
		}
	}

	private static Vector3 GetPos(Node node, Vector3 acc)
	{
		var x = acc.x >= 0
			? Mathf.Lerp(node.pos.x, node.max.x, acc.x)
			: Mathf.Lerp(node.pos.x, node.min.x, -acc.x);
		var y = acc.y >= 0
			? Mathf.Lerp(node.pos.y, node.max.y, acc.y)
			: Mathf.Lerp(node.pos.y, node.min.y, -acc.y);
		return new Vector3(x, y, node.pos.z);
	}

#if UNITY_EDITOR
	private void OnValidate()
	{
		ResetNodeList();
		InitNodeList();
	}

	private void ResetNodeList()
	{
		if (nodeList == null || center == Vector3.zero) return;
		foreach (var node in nodeList)
		{
			node.rect.localPosition = node.pos;
		}
	}
#endif

	private void OnGUI()
	{
#if UNITY_EDITOR || UNITY_STANDALONE_WIN
		GUILayout.Label($"screen:{Screen.width} * {Screen.height}");
		GUILayout.Label($"mou:{Input.mousePosition}");
		GUILayout.Label($"dir:{direction}");
		GUILayout.Label($"acc:{lastAcc}");
#else
		GUILayout.Space(100);
		GUILayout.Label(Input.acceleration.ToString());
#endif
		speed = GUILayout.HorizontalSlider(speed, 0, 5, GUILayout.Width(200));
	}
}