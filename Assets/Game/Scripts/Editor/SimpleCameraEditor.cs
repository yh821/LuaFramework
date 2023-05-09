using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(SimpleCamera))]
public class SimpleCameraEditor : Editor
{
	private SimpleCamera _camera;

	public override void OnInspectorGUI()
	{
		// DrawDefaultInspector();
		_camera = (SimpleCamera) target;

		_camera.target = (Transform) EditorGUILayout.ObjectField("目标", _camera.target, typeof(Transform), true);
		_camera.targetOffset = EditorGUILayout.Vector3Field("目标偏移", _camera.targetOffset);

		EditorGUILayout.LabelField($"焦距距离限制[最小:{_camera.minDistance} | 最大:{_camera.maxDistance}]");
		EditorGUILayout.MinMaxSlider(ref _camera.minDistance, ref _camera.maxDistance, 0.1f, 30f);
		EditorGUILayout.LabelField($"X轴旋转角度限制[最小:{_camera.minAngle} | 最大:{_camera.maxAngle}]");
		EditorGUILayout.MinMaxSlider(ref _camera.minAngle, ref _camera.maxAngle, -85, 85);

		_camera.angle = EditorGUILayout.Vector2Field("默认角度", _camera.angle);

		_camera.angleXSpeed = EditorGUILayout.Slider("X轴旋转速度", _camera.angleXSpeed, 0.01f, 1f);
		_camera.angleYSpeed = EditorGUILayout.Slider("Y轴旋转速度", _camera.angleYSpeed, 0.01f, 1f);
		_camera.rotationSensitivity = EditorGUILayout.Slider("旋转灵敏度", _camera.rotationSensitivity, 1f, 20f);
		_camera.distanceSensitivity = EditorGUILayout.Slider("焦距灵敏度", _camera.distanceSensitivity, 1f, 10f);

		_camera.maxTargetBias = EditorGUILayout.Slider("目标最大偏离", _camera.maxTargetBias, 0.01f, 10f);
		_camera.targetBiasLeap = EditorGUILayout.Slider("目标跟随速度", _camera.targetBiasLeap, 0.01f, 10f);
	}
}