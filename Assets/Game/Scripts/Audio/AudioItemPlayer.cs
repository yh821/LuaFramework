using System.Collections;
using UnityEngine;

namespace Game
{
	public sealed class AudioItemPlayer
	{
		private AudioSource source;
		private float delay;
		private float fadeInTime;
		private float fadeOutTime;
		private float startTime;
		private float stopTime;
		private float volume;

		internal AudioItemPlayer(AudioSource source, float delay = 0, float fadeInTime = 0, float fadeOutTime = 0)
		{
			this.source = source;
			this.delay = delay;
			this.fadeInTime = fadeInTime;
			this.fadeOutTime = fadeOutTime;
		}

		internal float Delay
		{
			get => delay;
			set => delay = value;
		}

		internal float FadeInTime
		{
			get => fadeInTime;
			set => fadeInTime = value;
		}

		internal float FadeOutTime
		{
			get => fadeOutTime;
			set => fadeOutTime = value;
		}

		internal bool IsPlaying => source != null && source.isPlaying;
		internal float PlayTime => source == null ? 0 : source.time;
		internal float TotalTime => source == null ? 0 : source.clip.length;
		internal bool IsFadeOut => stopTime > 0;

		internal void Play()
		{
			if (source == null) return;
			startTime = Time.realtimeSinceStartup;
			stopTime = -1f;
			volume = source.volume;
			if (delay > 0)
				source.PlayDelayed(delay);
			else
				source.Play();
		}

		internal void Stop()
		{
			if (fadeOutTime > 0)
				stopTime = Time.realtimeSinceStartup;
			else if (source != null)
			{
				source.Stop();
				source = null;
			}
		}

		internal void Update()
		{
			if (source == null) return;
			if (stopTime > 0)
			{
				var num = fadeOutTime - (Time.realtimeSinceStartup - stopTime);
				if (num > 0)
					source.volume = volume * (num / fadeOutTime);
				else
				{
					source.Stop();
					source = null;
					return;
				}
			}

			if (startTime <= 0) return;
			var num1 = fadeInTime - (Time.realtimeSinceStartup - startTime);
			if (num1 > 0)
				source.volume = volume * (1f - num1 / fadeInTime);
			else
			{
				source.volume = volume;
				startTime = -1f;
			}
		}
	}
}