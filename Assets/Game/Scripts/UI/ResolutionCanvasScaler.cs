using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(CanvasScaler))]
[ExecuteInEditMode]
public sealed class ResolutionCanvasScaler : MonoBehaviour
{
	private Canvas _canvas;
	private CanvasScaler _scaler;

	private void Start()
	{
		_canvas = GetComponent<Canvas>();
		_scaler = GetComponent<CanvasScaler>();
		if (_canvas == null || _canvas.isRootCanvas) return;
		AdaptResolution();
	}

#if UNITY_EDITOR || UNITY_STANDALONE
	private void Update()
	{
		AdaptResolution();
	}
#endif

	private void AdaptResolution()
	{
#if UNITY_EDITOR
		var prefabType = PrefabUtility.GetPrefabType(gameObject);
		if (prefabType == PrefabType.Prefab) return;
#endif
		var radio = (float) Screen.width / Screen.height;
		var referenceRadio = _scaler.referenceResolution.x / _scaler.referenceResolution.y;
		if (radio > referenceRadio)
			_scaler.matchWidthOrHeight = 1f;
		else
			_scaler.matchWidthOrHeight = 0;
	}
}