using UnityEditor;
using UnityEngine;

namespace Game
{
	public class GameObjectAttach : MonoBehaviour, IGameObjectAttach
	{
		public float delayTime = 0;
		public int attachLayer = -1;

		private bool isDisableEffect = false;

		// private SRPEffect srpEffect;
		private int effectQualityBisa = 0;

		[SerializeField] private AssetID asset;

		public AssetID Asset
		{
			get => asset;
			set
			{
				if (!asset.Equals(value)) asset = value;
			}
		}

		public string BundleName
		{
			get => asset.BundleName;
			set => asset.BundleName = value;
		}

		public string AssetName
		{
			get => asset.AssetName;
			set => asset.AssetName = value;
		}

#if UNITY_EDITOR
		public string AssetGuid
		{
			get => asset.AssetGuid;
			set => asset.AssetGuid = value;
		}

		private GameObject previewGameObj;
#endif

		public bool Loaded { get; private set; }

		private void OnDestroy()
		{
			if (EventDispatcher.Instance != null)
				EventDispatcher.Instance.OnGameObjAttachDestroy(this);
		}

		private bool _disable;
		private bool _isUi;

		private void OnDisable()
		{
#if UNITY_EDITOR
			DestroyAttachObj();
#endif
			if (EventDispatcher.Instance != null)
				EventDispatcher.Instance.OnGameObjAttachDisable(this);

			Loaded = false;
			_disable = true;
		}

#if UNITY_EDITOR

		private bool dirty = false;

		private void OnValidate()
		{
			dirty = true;
		}

		private void Update()
		{
			if (Application.isPlaying) return;
			if (dirty)
			{
				dirty = false;
				CreateAttachObj();
			}
		}

		private void DestroyAttachObj()
		{
			if (!Application.isPlaying)
			{
				var previewObj = gameObject.GetComponent<PreviewObject>();
				if (previewObj) previewObj.ClearPreview();
				if (previewGameObj != null)
				{
					Destroy(previewGameObj);
					previewGameObj = null;
				}
			}
		}

		private void CreateAttachObj()
		{
			DestroyAttachObj();
			var isPlayingEditMode = false;
			isPlayingEditMode = Application.isPlaying &&
			                    UnityEditor.SceneManagement.EditorSceneManager.IsPreviewSceneObject(transform);
			if (!isPlayingEditMode)
			{
				if (!(string.IsNullOrEmpty(BundleName) || string.IsNullOrEmpty(AssetName)))
				{
					var asset = EditorResourceMgr.LoadGameObject(BundleName, AssetName);
					if (asset != null)
					{
						var go = Instantiate(asset);
						if (Application.isPlaying)
						{
							go.transform.SetParent(transform, false);
							previewGameObj = go;
						}
						else
						{
							var previewObj = gameObject.GetComponent<PreviewObject>() ??
							                 gameObject.AddComponent<PreviewObject>();
							previewObj.SimulateInEditMode = true;
							previewObj.SetPreview(go);
						}
					}
				}
			}
		}

		public void RefreshAssetBundleName()
		{
			var assetPath = AssetDatabase.GUIDToAssetPath(AssetGuid);
			var importer = AssetImporter.GetAtPath(assetPath);
			if (importer != null)
			{
				BundleName = importer.assetBundleName;
				AssetName = assetPath.Substring(assetPath.LastIndexOf('/') + 1);
			}
		}

		public bool IsGameObjectMissing()
		{
			var assetPath = AssetDatabase.GUIDToAssetPath(AssetGuid);
			var importer = AssetImporter.GetAtPath(assetPath);
			if (importer == null)
				return true;
			if (BundleName != importer.assetBundleName ||
			    AssetName != assetPath.Substring(assetPath.LastIndexOf('/') + 1))
				return true;
			return false;
		}
#endif
	}
}