using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(RectTransform))]
public class SafeAreaAdpater : MonoBehaviour
{
	/// <summary>
	/// 设计分辨率宽度
	/// </summary>
	public const int ReferenceWidth = 1366;

	/// <summary>
	/// 设计分辨率高度
	/// </summary>
	public const int ReferenceHeight = 768;
}