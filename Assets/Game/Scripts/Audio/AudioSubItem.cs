using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

namespace Game
{
	[Serializable]
	public struct AudioSubItem
	{
		[SerializeField] private AudioClip audioClip;
		[SerializeField] private AudioMixerGroup outputAudioMixerGroup;
		[SerializeField] private float weight;
		[SerializeField] [Range(0, 1f)] private float volume;
		[SerializeField] [Range(0, 1f)] private float randomVolume;
		[SerializeField] private float pitch;
		[SerializeField] private float randomPitch;
		[SerializeField] private float delay;
		[SerializeField] private float randomDelay;
		[SerializeField] private float startAt;
		[SerializeField] private float randomStartAt;
		[SerializeField] private float fadeInTime;
		[SerializeField] private float fadeOutTime;

		public AudioClip Clip => audioClip;
		public AudioMixerGroup MixerGroup => outputAudioMixerGroup;
		public float Weight => weight;

		public void Reset()
		{
			audioClip = null;
			outputAudioMixerGroup = null;
			weight = 0;
			volume = 1;
			randomVolume = 0;
			pitch = 1;
			randomPitch = 0;
			delay = 0;
			randomDelay = 0;
			startAt = 0;
			randomStartAt = 0;
			fadeInTime = 0;
			fadeOutTime = 0;
		}

		public float GetVolume()
		{
			return volume + UnityEngine.Random.Range(-1f, 1f) * randomVolume;
		}

		public float GetPitch()
		{
			return pitch + UnityEngine.Random.Range(-1f, 1f) * randomPitch;
		}

		public float GetDelay()
		{
			return delay + UnityEngine.Random.Range(-1f, 1f) * randomDelay;
		}

		public float GetStartAt()
		{
			return startAt + UnityEngine.Random.Range(-1f, 1f) * randomStartAt;
		}

		public float GetFadeInTime()
		{
			return fadeInTime;
		}

		public float GetFadeOutTime()
		{
			return fadeOutTime;
		}
	}
}