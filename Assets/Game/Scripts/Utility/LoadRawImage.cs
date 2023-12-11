using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(RawImage))]
[ExecuteInEditMode]
public class LoadRawImage : MonoBehaviour
{
	public string BundleName;
	public string AssetName;

	public bool AutoFitNatvieSize;
	public bool AutoUpdateAspectRatio;

	private RawImage _rawImage;

#if UNITY_EDITOR
	private bool isDirty = false;
#endif

	private void Awake()
	{
		_rawImage = gameObject.GetComponent<RawImage>();
		_rawImage.enabled = false;
	}

	private void OnDestroy()
	{
		if (EventDispatcher.Instance != null)
		{

		}
	}

	// Start is called before the first frame update
	void Start()
	{
	}

	// Update is called once per frame
	void Update()
	{
	}
}