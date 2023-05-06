using System;
using UnityEngine;

[DisallowMultipleComponent]
public sealed class MoveableObject : MonoBehaviour
{
	private static int[] _levelToLayer;
	private static int[] _levelToNav;

	public float moveSpeed = 5f;
	private bool moving;
	private Vector3 moveTarget;
	private Action<int> rotateCallback;

	public float rotateSpeed = 1f;
	private bool rotating;
	private Quaternion rotateTarget;
	private Action<int> moveCallback;

	public void Reset()
	{
		moving = false;
		rotating = false;
	}

	public void MoveTo(float x, float y, float z, float speed, Action<int> callback = null)
	{
		MoveTo(new Vector3(x, y, z), speed, callback);
	}

	public void MoveTo(Vector3 target, float speed, Action<int> callback = null)
	{
		moveTarget = target;
		moveTarget.y = 0;
		moveSpeed = speed;
		moving = true;
		moveCallback = callback;
	}

	public void StopMove()
	{
		if (!moving) return;
		moving = false;
		moveCallback?.Invoke(1);
	}

	public void RotateTo(Vector3 target, float speed)
	{
		var delta = target - transform.position;
		delta.y = 0;
		if (delta.sqrMagnitude > float.Epsilon)
		{
			rotateTarget = Quaternion.LookRotation(delta);
			rotateSpeed = speed;
			rotating = true;
		}
	}

	public void StopRotate()
	{
		if (!rotating) return;
		rotating = false;
		rotateCallback?.Invoke(1);
	}

	// Update is called once per frame
	private void Update()
	{
		if (moving && rotating)
		{
			var position = DoPosition(transform.position);
			var rotation = DoRotation(transform.rotation);
			transform.SetPositionAndRotation(position, rotation);
		}
		else if (moving)
		{
			var position = DoPosition(transform.position);
			transform.position = position;
		}
		else if (rotating)
		{
			var rotation = DoRotation(transform.rotation);
			transform.rotation = rotation;
		}
	}

	private Vector3 DoPosition(Vector3 source)
	{
		var pos = source;
		pos.y = 0f;
		var move = moveTarget - source;
		move.y = 0;
		var delta = Time.deltaTime * moveSpeed;
		if (delta * delta > move.sqrMagnitude || move == Vector3.zero)
		{
			pos = moveTarget;
			moving = false;
			moveCallback?.Invoke(0);
		}
		else
		{
			pos += move.normalized * delta;
		}

		pos.y = source.y;
		return pos;
	}

	private Quaternion DoRotation(Quaternion rotation)
	{
		var delta = Time.deltaTime;
		rotation = Quaternion.Slerp(rotation, rotateTarget, delta * rotateSpeed);
		var angle = Quaternion.Angle(rotation, rotateTarget);
		if (angle < 0.01f)
		{
			rotation = rotateTarget;
			rotating = false;
			rotateCallback?.Invoke(0);
		}

		return rotation;
	}

	public static float GetWalkableHeight(float x, float z, int level = -1)
	{
		var mask = GetMaskByWalkableLevel(level);
		return GetHeightByLayerMask(x, z, mask);
	}

	private static float GetHeightByLayerMask(float x, float z, int layerMask)
	{
		var source = new Vector3(x,10000,z);
		return Physics.Raycast(source, Vector3.down, out var hit, 20000, layerMask)
			? hit.point.y
			: float.NegativeInfinity;
	}

	private static int GetMaskByWalkableLevel(int level)
	{
#if UNITY_EDITOR
		CreateMaskArray();
#endif
		int mask;
		switch (level)
		{
			case -1:
				//所有可行走layer
				mask = _levelToLayer[1];
				break;
			default:
				mask = _levelToLayer[0];
				break;
		}

		return mask;
	}

	private static void CreateMaskArray()
	{
		if (_levelToLayer == null)
		{
			_levelToLayer = new int[2];
			_levelToLayer[0] = (1 << GameLayers.Walkable) |
			                   (1 << GameLayers.Road);
			_levelToLayer[1] = (1 << GameLayers.Walkable) |
			                   (1 << GameLayers.Road) |
			                   (1 << GameLayers.Water);
		}

		if (_levelToNav == null)
		{
			_levelToNav = new int[2];
			_levelToNav[0] = (1 << NavMeshLayers.Walkable) |
			                 (1 << NavMeshLayers.Water) |
			                 (1 << NavMeshLayers.Road);
		}
	}
}