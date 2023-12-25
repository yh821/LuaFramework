using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;

namespace Game
{
	[DisallowMultipleComponent]
	public class GameObjectPool : Singleton<GameObjectPool>
	{
		private Dictionary<GameObject, GameObjectCache> objectCaches = new Dictionary<GameObject, GameObjectCache>();

		public GameObjectPool()
		{
		}

		public GameObject Spawn(GameObject prefab, Transform parent)
		{
			Assert.IsNotNull(prefab);
			if (!objectCaches.TryGetValue(prefab, out var gameObjectCache))
			{

			}
			return gameObjectCache.Spawn(parent);
		}

		public void SetDefaultReleaseAfterFree(AssetID assetId, int value)
		{
		}

		public void Free(GameObject instance, bool destroy = false)
		{
		}

		public void Clear()
		{
		}

		public void ClearAllUnused()
		{
		}

		private void SweepCache()
		{
		}
	}
}