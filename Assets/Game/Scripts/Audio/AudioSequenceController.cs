using System.Collections;
using System.Collections.Generic;
using Game;
using UnityEngine;

namespace Game
{
	public class AudioSequenceController : IAudioController
	{
		private AudioItem item;
		private AudioSourcePool pool;
		private AudioSource source;
		private AudioItemPlayer player;
		private AudioSubItem[] subItems;
		private bool stopped;
		private int playIndex;
		private Transform transform;

		internal AudioSequenceController(
			AudioSourcePool pool,
			AudioItem item,
			AudioSource source,
			AudioSubItem[] subItems)
		{
			this.item = item;
			this.pool = pool;
			this.source = source;
			this.subItems = subItems;
			player = new AudioItemPlayer(source);
		}

		public bool IsPlaying => !stopped || player.IsPlaying;
		public float LeftTime => stopped ? 0 : player.TotalTime - player.PlayTime;

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
			stopped = true;
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
			stopped = false;
			playIndex = 0;
			PlayCurrentSubItem();
		}

		public void Update()
		{
			if (stopped && !player.IsPlaying) return;
			if (transform != null)
			{
				source.transform.SetPositionAndRotation(transform.position, transform.rotation);
				source.transform.localScale = transform.localScale;
			}

			player.Update();
			if (player.TotalTime - player.PlayTime <= player.FadeOutTime && !player.IsFadeOut)
				player.Stop();
			if (stopped || player.IsPlaying) return;
			playIndex = (playIndex + 1) % subItems.Length;
			PlayCurrentSubItem();
		}

		public void FinishAudio()
		{
			if (item != null) item.ReducePlayingCount(this);
			pool?.Free(source);
		}

		private void PlayCurrentSubItem()
		{
			var subItem = subItems[playIndex];
			item.SetupAudioSource(source,subItem);
			player.Delay = item.Delay + subItem.GetDelay();
			player.FadeInTime = subItem.GetFadeInTime();
			player.FadeOutTime = subItem.GetFadeOutTime();
			player.Play();
		}
	}
}