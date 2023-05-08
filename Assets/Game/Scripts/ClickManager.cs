using UnityEngine;

[RequireComponent(typeof(Camera))]
public sealed class ClickManager : MonoBehaviour
{
	static RaycastHit[] clickableHits = new RaycastHit[20];
	static RaycastHit[] sceneHits = new RaycastHit[20];

	private Rect reserveRect;
	private Camera lookCamera;

	public delegate void ClickGroundDelegate(RaycastHit hit);

	private ClickGroundDelegate clickGroundEvent;
	public static ClickManager Instance { get; private set; }

	//TODO 摄像机点击
}