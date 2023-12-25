using System.Collections;
using UnityEngine;

namespace Game
{
	public class AudioSingleController : IAudioController
	{
		private AudioItem item;
		private AudioSourcePool pool;
		private AudioSource source;
		private AudioItemPlayer player;
		private Transform transform;

		internal AudioSingleController(AudioSourcePool pool, AudioItem item, AudioSubItem subItem, bool loop)
		{
			source = pool.Allocate(item.name);
			source.loop = loop;
			item.SetupAudioSource(source, subItem);
			var delay = item.Delay + subItem.GetDelay();
			var fadeInTime = subItem.GetFadeInTime();
			var fadeOutTime = subItem.GetFadeOutTime();
			player = new AudioItemPlayer(source, delay, fadeInTime, fadeOutTime);
			this.pool = pool;
			this.item = item;
		}

		public bool IsPlaying => player.IsPlaying;
		public float LeftTime => player.TotalTime - player.PlayTime;

		public override string ToString()
		{
			return item.name;
		}

		public IEnumerator WaitFinish()
		{
			return new WaitUntil(() => !IsPlaying);
		}

		public void Stop()
		{
			player.Stop();
		}

		public void SetPosition(Vector3 position)
		{
			source.transform.position = position;
		}

		public void SetTransform(Transform transform)
		{
			this.transform = transform;
		}

		public void Play()
		{
			player.Play();
		}

		public void Update()
		{
			if (transform != null)
			{
				source.transform.SetPositionAndRotation(transform.position, transform.rotation);
				source.transform.localScale = transform.localScale;
			}

			player.Update();
		}

		public void FinishAudio()
		{
			if (item != null) item.ReducePlayingCount(this);
			pool?.Free(source);
		}
	}
}