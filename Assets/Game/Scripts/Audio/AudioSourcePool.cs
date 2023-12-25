using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Game
{
	public sealed class AudioSourcePool
	{
		private Stack<AudioSource> cache = new Stack<AudioSource>();
		private Transform usingRoot;
		private Transform cacheRoot;

		public AudioSourcePool(Transform usingRoot, Transform cacheRoot)
		{
			this.usingRoot = usingRoot;
			this.cacheRoot = cacheRoot;
		}

		internal AudioSource Allocate(string name)
		{
			AudioSource source;
			if (cache.Count > 0)
			{
				source = cache.Pop();
				source.name = name;
			}
			else
				source = new GameObject(name).AddComponent<AudioSource>();

			source.transform.parent = usingRoot;
			source.gameObject.SetActive(true);
			return source;
		}

		internal void Free(AudioSource source)
		{
			source.name = "Free Audio Source";
			source.transform.parent = cacheRoot;
			source.clip = null;
			source.outputAudioMixerGroup = null;
			source.gameObject.SetActive(false);
			cache.Push(source);
		}
	}
}