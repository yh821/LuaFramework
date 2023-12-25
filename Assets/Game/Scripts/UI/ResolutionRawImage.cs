using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(RectTransform))]
[ExecuteInEditMode]
public sealed class ResolutionRawImage : MonoBehaviour
{
	[SerializeField] private RawImage rawImage;
	[SerializeField] private bool isLimitScale;
	[SerializeField] private Vector2 customSize;

	[SerializeField] private bool isMatch;
	[SerializeField] [Range(0, 1)] private float matchWidthOrHeight;

	private Rect _rawImageRect;
	private Rect _parentRect;
	private RectTransform _parentRectTrans;

	private void OnDidApplyAnimationProperties()
	{
		_parentRectTrans = GetComponent<RectTransform>();
		_parentRectTrans.anchorMin = Vector2.zero;
		_parentRectTrans.anchorMax = Vector2.one;
		_parentRectTrans.pivot = new Vector2(0.5f, 0.5f);
	}

	private void Start()
	{
		AdaptResolution();
	}

	private void Update()
	{
#if !UNITY_EDITOR
		if (_parentRect != _parentRectTrans.rect || (rawImage != null && _rawImageRect != rawImage.rectTransform.rect))
#endif
		{
			AdaptResolution();
		}
	}

	private void AdaptResolution()
	{
#if UNITY_EDITOR
		var prefabType = PrefabUtility.GetPrefabType(gameObject);
		if (prefabType == PrefabType.Prefab) return;
#endif
		if (rawImage == null || rawImage.texture == null) return;
		_parentRect = _parentRectTrans.rect;
		if (_parentRect.width == 0 || _parentRect.height == 0) return;

		var imageRectTrans = rawImage.rectTransform;
		_rawImageRect = imageRectTrans.rect;
		if (_rawImageRect.width == 0 || _rawImageRect.height == 0) return;

		imageRectTrans.anchorMin = new Vector2(0.5f, 0.5f);
		imageRectTrans.anchorMax = new Vector2(0.5f, 0.5f);
		imageRectTrans.pivot = new Vector2(0.5f, 0.5f);

		if (customSize.x > 0 && customSize.y > 0)
			imageRectTrans.sizeDelta = customSize;
		else
			rawImage.SetNativeSize();

		var scaleX = 1f;
		var scaleY = 1f;
		if (isLimitScale)
		{
			scaleX = _parentRect.width / _rawImageRect.width;
			scaleY = _parentRect.height / _rawImageRect.height;
		}
		else
		{
			if (_rawImageRect.width < _parentRect.width)
				scaleX = _parentRect.width / _rawImageRect.width;
			if (_rawImageRect.height < _parentRect.height)
				scaleY = _parentRect.height / _rawImageRect.height;
		}

		var scale = isMatch ? Mathf.Lerp(scaleX, scaleY, matchWidthOrHeight) : Mathf.Max(scaleX, scaleY);
		if (scale != imageRectTrans.localScale.x || scale != imageRectTrans.localScale.y)
			imageRectTrans.localScale = new Vector3(scale, scale, scale);
	}
}