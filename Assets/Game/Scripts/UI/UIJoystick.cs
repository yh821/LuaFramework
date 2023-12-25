using System;
using Game;
using HedgehogTeam.EasyTouch;
using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.SceneManagement;

public sealed class UIJoystick : MonoBehaviour
{
	public enum JoystickMode
	{
		[EnumLabel("固定遥感")]Fixed,
		[EnumLabel("全屏遥感")]Dynamic,
		[EnumLabel("范围遥感")]LocalDynamic
	}

	[SerializeField] [Tooltip("摇杆最大半径")] private float radius = 80;
	[SerializeField] [Tooltip("可视物体根节点")] private GameObject visibleRoot;
	[SerializeField] [Tooltip("遥感对象")] private RectTransform thumb;
	[SerializeField] [Tooltip("遥感背景")] private RectTransform thumbBg;
	[SerializeField] [Tooltip("遥感模式")] [EnumLabel] private JoystickMode mode;
	[SerializeField] [Tooltip("触发事件间隔")] private float interval = 0.1f;
	[SerializeField] [Tooltip("是否旋转背景")] private bool rotateBg;
	[SerializeField] [Tooltip("是否自动隐藏")] private bool autoFade;
	[SerializeField] [Tooltip("移动范围(范围遥感模式下才生效)")] private Rect moveRange;

	private Canvas _canvas;
	private int? _fingerIndex;
	private float _lastEventTime = -1f;
	private Vector2 _localPos = Vector2.zero;
	private Vector2 _offset = Vector2.zero;
	private RectTransform _thrumParent;

	public Action<float, float> onDragBegin;
	public Action<float, float> onDragUpdate;
	public Action<float, float> onDragEnd;
	public Action<bool, int> onTouched;

	public void SetDynamicRange(int x, int y, int width, int height)
	{
		moveRange = new Rect(x, y, width, height);
	}

	public void AddDragBeginListener(Action<float, float> listener)
	{
		onDragBegin += listener;
	}

	public void AddDragUpdateListener(Action<float, float> listener)
	{
		onDragUpdate += listener;
	}

	public void AddDragEndListener(Action<float, float> listener)
	{
		onDragEnd += listener;
	}

	public void AddTouchedListener(Action<bool, int> listener)
	{
		onTouched += listener;
	}

	private void Awake()
	{
		// _canvas = GetComponentInParent<Canvas>();
		_canvas = GameObject.Find("GameRoot/UiLayer").GetComponent<Canvas>();
		Assert.IsNotNull(_canvas);

		if (!thumb) thumb = (RectTransform) gameObject.transform.Find("thumb");
		Assert.IsNotNull(thumb);

		if (!thumbBg) thumbBg = (RectTransform) gameObject.transform.Find("thumbBg");
		Assert.IsNotNull(thumbBg);

		_thrumParent = (RectTransform) thumb.parent;
		Assert.IsNotNull(_thrumParent);

		if (mode == JoystickMode.Dynamic && autoFade)
			visibleRoot.SetActive(false);

		if (mode == JoystickMode.Fixed)
		{
			EasyTouch.On_SwipeStart += OnDragBeginHandler;
			EasyTouch.On_Swipe += OnDragHandler;
			EasyTouch.On_SwipeEnd += OnDragEndHandler;
		}
		else
		{
			EasyTouch.On_TouchStart += OnDragBeginHandler;
			EasyTouch.On_TouchDown += OnDragHandler;
			EasyTouch.On_TouchUp += OnDragEndHandler;
		}

		EasyTouch.On_Cancel += OnDragCancel;
		SceneManager.activeSceneChanged += OnChangeScene;
	}

	private void Start()
	{
		_localPos = visibleRoot.transform.localPosition;
	}

	private void Update()
	{
		if (_fingerIndex == null) return;
		if (Time.realtimeSinceStartup < _lastEventTime + interval) return;
		_lastEventTime = Time.realtimeSinceStartup;
		onDragUpdate?.Invoke(_offset.x, _offset.y);
	}

	private void OnDestroy()
	{
		if (mode == JoystickMode.Fixed)
		{
			EasyTouch.On_SwipeStart -= OnDragBeginHandler;
			EasyTouch.On_Swipe -= OnDragHandler;
			EasyTouch.On_SwipeEnd -= OnDragEndHandler;
		}
		else
		{
			EasyTouch.On_TouchStart -= OnDragBeginHandler;
			EasyTouch.On_TouchDown -= OnDragHandler;
			EasyTouch.On_TouchUp -= OnDragEndHandler;
		}

		EasyTouch.On_Cancel -= OnDragCancel;
		SceneManager.activeSceneChanged -= OnChangeScene;
	}

	private void Release()
	{
		if (_fingerIndex != null) onTouched?.Invoke(false, -1);
		_fingerIndex = null;
		_offset = Vector2.zero;
		if (mode == JoystickMode.Dynamic)
		{
			if (autoFade) visibleRoot.SetActive(false);
			visibleRoot.transform.localPosition = _localPos;
		}
		else if (mode == JoystickMode.LocalDynamic)
			visibleRoot.transform.localPosition = _localPos;

		thumb.localPosition = Vector2.zero;
		if (rotateBg) thumbBg.transform.localRotation = Quaternion.identity;
		onDragEnd?.Invoke(_offset.x, _offset.y);
	}

	private void OnDragBeginHandler(Gesture gesture)
	{
		if (!thumb || _fingerIndex != null) return;
		var startPos = gesture.startPosition;
		var inRange = moveRange.Contains(startPos);
		if (mode == JoystickMode.Fixed || mode == JoystickMode.LocalDynamic && !inRange)
		{
			var rect = (RectTransform) visibleRoot.transform;
			if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, startPos, _canvas.worldCamera,
				out var position)) return;
			if (!rect.rect.Contains(position)) return;
		}
		else if (mode == JoystickMode.Dynamic || mode == JoystickMode.LocalDynamic && inRange)
		{
			var rect = (RectTransform) visibleRoot.transform.parent;
			if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, startPos, _canvas.worldCamera,
				out var position)) return;
			visibleRoot.transform.localPosition = position;
		}

		_fingerIndex = gesture.fingerIndex;
		onTouched?.Invoke(true, _fingerIndex.Value);
		onDragBegin?.Invoke(0, 0);
		_lastEventTime = -1;
	}

	private void OnDragHandler(Gesture gesture)
	{
		if (gesture.fingerIndex != _fingerIndex) return;
		if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(_thrumParent, gesture.position,
			_canvas.worldCamera, out var localPoint)) return;
		var sqrMagnitude = localPoint.sqrMagnitude;
		if (sqrMagnitude > radius * radius)
		{
			var modifier = Mathf.Sqrt(sqrMagnitude);
			modifier = radius / modifier;
			localPoint *= modifier;
		}

		_offset.x = localPoint.x;
		_offset.y = localPoint.y;
		thumb.localPosition = localPoint;
		if (rotateBg)
		{
			var angle = (float) (Math.Atan2(localPoint.y, localPoint.x) * Mathf.Rad2Deg);
			thumbBg.localEulerAngles = new Vector3(0, 0, angle + 90);
		}
	}

	private void OnDragEndHandler(Gesture gesture)
	{
		if (gesture.fingerIndex != _fingerIndex) return;
		Release();
	}

	private void OnDragCancel(Gesture gesture)
	{
		OnDragEndHandler(gesture);
	}

	private void OnChangeScene(Scene from, Scene to)
	{
		Release();
	}
}