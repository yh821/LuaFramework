using System;
using HedgehogTeam.EasyTouch;
using UnityEngine;
using UnityEngine.Serialization;

public class SimpleCamera : MonoBehaviour
{
	public float minAngle = -5f;
	public float maxAngle = 60f;
	public float minDistance = 1f;
	public float maxDistance = 20f;

	public float angleXSpeed = 0.5f;
	public float angleYSpeed = 0.5f;
	public float rotationSensitivity = 4;
	public float distanceSensitivity = 2;

	public float maxTargetBias = 2;
	public float targetBias = 0.2f;
	public float targetBiasLeap = 5;

	public bool StopCameraUpdate { get; set; }

	public Transform target;
	public Vector3 targetOffset;
	private Vector3 _lastTargetPos;

	private float _distance = 10;
	private float _oldDistance;

	private Vector2 _angle;
	private Vector2 _oldAngle;

	private float _touchGroundDis = 0;
	private Transform _cachedTransform;

	private void Awake()
	{
		_cachedTransform = transform;
		_oldDistance = _distance;
		_oldAngle = _angle;

		EasyTouch.On_Swipe += OnSwipe;
		EasyTouch.On_Pinch += OnPinch;
	}

	private void Start()
	{
		if (!target) return;
		SetCameraPosition(_oldDistance, Quaternion.Euler(_oldAngle.x, _oldAngle.y, 0));
	}

	private void LateUpdate()
	{
		if (StopCameraUpdate || !target) return;
		UpdatePosition();
	}

	private void OnSwipe(Gesture gesture)
	{
		var x = Mathf.Clamp(gesture.swipeVector.x, -20, 20);
		Swipe(x, gesture.swipeVector.y);
	}

	private void OnPinch(Gesture gesture)
	{
		Pinch(gesture.deltaPinch);
	}

	private void Swipe(float x, float y)
	{
		if (x == 0 || Mathf.Abs(y / x) > 1f)
		{
			bool pitch;
			if (y > 0) //仰视
			{
				pitch = _angle.x <= minAngle;
				if (pitch && _touchGroundDis <= 0)
					_touchGroundDis = Mathf.Min(_distance, maxDistance);
				;
			}
			else //俯视，拉远到触地前距离就停止
				pitch = 0 < _touchGroundDis && _distance < _touchGroundDis;

			if (pitch)
				Pinch(y * 2);
			else
			{
				_angle.x += -y * angleXSpeed;
				_angle.x = Mathf.Clamp(_angle.x, minAngle, maxAngle);
			}
		}

		if (x != 0)
		{
			_angle.y += x * angleYSpeed;
		}
	}

	private void Pinch(float delta)
	{
		if (StopCameraUpdate) return;
		if (delta < 0 || _distance > minDistance)
		{
			var temp = _distance + delta * -0.03f;
			temp = Mathf.Clamp(temp, minDistance, maxDistance);
			if (_touchGroundDis > 0 && temp >= _touchGroundDis)
			{
				temp = _touchGroundDis;
				_touchGroundDis = 0; //超过触地前距离就取消变化
			}

			_distance = temp;
			_oldDistance = temp;
		}
	}

	private void UpdatePosition()
	{
		var targetY = FixTargetAngle(_oldAngle.y, _angle.y);
		_oldAngle = Vector2.Lerp(_oldAngle, new Vector2(_angle.x, targetY), Time.deltaTime * rotationSensitivity);
		_oldDistance = Mathf.Lerp(_oldDistance, _distance, Time.deltaTime * distanceSensitivity);
		SetCameraPosition(_oldDistance, Quaternion.Euler(_oldAngle.x, _oldAngle.y, 0));
	}

	private void SetCameraPosition(float nowDistance, Quaternion nowQuaternion)
	{
		var targetPos = target.position;
		if (targetPos != _lastTargetPos)
		{
			var maxBias = Mathf.Min(nowDistance * targetBias, maxTargetBias);
			var lastTargetPos = Vector3.Lerp(_lastTargetPos, targetPos, Time.deltaTime * targetBiasLeap);
			if ((lastTargetPos - targetPos).sqrMagnitude > maxBias * maxBias)
				lastTargetPos = targetPos + (lastTargetPos - targetPos).normalized * maxBias;
			targetPos = lastTargetPos;
			_lastTargetPos = lastTargetPos;
		}

		_cachedTransform.position = targetPos + targetOffset + nowQuaternion * Vector3.back * nowDistance;
		_cachedTransform.rotation = nowQuaternion;
	}

	private float FixTargetAngle(float source, float target)
	{
		target = (target - source) % 360f;
		if (target < -180f)
			target += 360f;
		else if (target > 180f)
			target -= 360f;
		return source + target;
	}

	public void MoveToTarget()
	{
		if (target)
		{
			_oldDistance = _distance;
			_oldAngle = _angle;
		}
	}

	public void ChangeAngle(Vector2 angle)
	{
		_angle = angle;
		_angle.x %= 360f;
		if (_angle.x > 180f)
			_angle.x -= 180f;
		_angle.x = Mathf.Clamp(_angle.x, minAngle, maxAngle);
		_angle.y %= 360f;
	}
}