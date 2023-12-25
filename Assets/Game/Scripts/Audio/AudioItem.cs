using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Audio;

namespace Game
{
	[CreateAssetMenu(fileName = "AudioItem", menuName = "Game/Audio/AudioItem")]
	public class AudioItem : ScriptableObject
	{
		private enum AudioPlayMode
		{
			[EnumLabel("顺序播放")] SequencePick,
			[EnumLabel("乱序播放")] ShufflePick,
			[EnumLabel("随机播放")] RandomPick,
			[EnumLabel("顺序循环")] SequenceLoop,
			[EnumLabel("乱序循环")] ShuffleLoop,
		}

		[SerializeField] [Range(0, 1f)] [Tooltip("总音量")]
		private float volume = 1;

		[SerializeField] [Tooltip("延时时长")] private float delay = 1;
		[SerializeField] [Range(0, 1f)] private float spatialBlend = 1;
		[SerializeField] private float interval = 0;
		[SerializeField] private int maxCount = 0;
		[SerializeField] [EnumLabel] private AudioPlayMode playMode;
		[SerializeField] private AudioSubItem[] subItems;
		[SerializeField] private AudioMixerGroup outputAudioMixerGroup;
		[SerializeField] private AudioGroup audioGroup;

		public float Delay => delay;

		private AudioSubItem[] sequence;
		private int index;
		private float lastTime;
		private int playingCount;

		public AudioItem()
		{
			EditorApplication.playmodeStateChanged += Reset;
		}

		public void PlaySubItem(int index, AudioSource source)
		{
			var subItem = subItems[index];
			SetupAudioSource(source, subItem);
		}

		internal void SetupAudioSource(AudioSource source, AudioSubItem subItem)
		{
			source.transform.SetPositionAndRotation(Vector3.zero, Quaternion.identity);
			source.transform.localScale = Vector3.one;
			source.clip = subItem.Clip;
			source.outputAudioMixerGroup = subItem.MixerGroup == null ? outputAudioMixerGroup : subItem.MixerGroup;
			source.volume = volume * subItem.GetVolume();
			source.pitch = subItem.GetPitch();
			source.spatialBlend = spatialBlend;
		}

		internal void ReducePlayingCount(IAudioController ctrl)
		{
			playingCount--;
			if (audioGroup == null) return;
			audioGroup.StopPlaying(ctrl);
		}

		public IAudioController Play(AudioSourcePool pool)
		{
			if (subItems.Length == 0
			    || Time.realtimeSinceStartup < lastTime + interval
			    || maxCount > 0 && playingCount >= maxCount
			    || audioGroup != null && !audioGroup.CheckPlayableAndTryToEliminate())
				return AudioDummyController.Default;
			playingCount++;
			lastTime = Time.realtimeSinceStartup;
			IAudioController ctrl;
			switch (playMode)
			{
				case AudioPlayMode.SequencePick:
					ctrl = PlaySequencePick(pool);
					break;
				case AudioPlayMode.ShufflePick:
					ctrl = PlayShufflePick(pool);
					break;
				case AudioPlayMode.RandomPick:
					ctrl = PlayRandomPick(pool);
					break;
				case AudioPlayMode.SequenceLoop:
					ctrl = PlaySequenceLoop(pool);
					break;
				case AudioPlayMode.ShuffleLoop:
					ctrl = PlayShuffleLoop(pool);
					break;
				default:
					ctrl = AudioDummyController.Default;
					break;
			}

			if (audioGroup != null && ctrl != AudioDummyController.Default)
				audioGroup.AddPlaying(ctrl);
			return ctrl;
		}

		private IAudioController PlaySequencePick(AudioSourcePool pool)
		{
			if (index >= subItems.Length) index = 0;
			var subItem = subItems[index++];
			return new AudioSingleController(pool, this, subItem, false);
		}

		private IAudioController PlayShufflePick(AudioSourcePool pool)
		{
			if (sequence == null || sequence.Length != subItems.Length)
			{
				sequence = new AudioSubItem[subItems.Length];
				for (int i = 0; i < subItems.Length; i++)
					sequence[i] = subItems[i];
				index = 0;
				sequence.Shuffle();
			}

			if (index >= subItems.Length)
			{
				index = 0;
				sequence.Shuffle();
			}

			var subItem = sequence[index++];
			return new AudioSingleController(pool, this, subItem, false);
		}

		private IAudioController PlayRandomPick(AudioSourcePool pool)
		{
			var num1 = 0f;
			foreach (var subItem in subItems)
				num1 += subItem.Weight;
			if (Mathf.Approximately(num1, 0))
			{
				var subItem = subItems[Random.Range(0, subItems.Length)];
				return new AudioSingleController(pool, this, subItem, false);
			}

			var num2 = Random.Range(0, num1);
			foreach (var subItem in subItems)
			{
				num2 -= subItem.Weight;
				if (num2 <= 0)
					return new AudioSingleController(pool, this, subItem, false);
			}

			return AudioDummyController.Default;
		}

		private IAudioController PlaySequenceLoop(AudioSourcePool pool)
		{
			if (subItems.Length == 1)
			{
				var subItem = subItems[0];
				return new AudioSingleController(pool,this,subItem,true);
			}

			var source = pool.Allocate(name);
			source.loop = false;
			return new AudioSequenceController(pool, this, source, subItems);
		}

		private IAudioController PlayShuffleLoop(AudioSourcePool pool)
		{
			return AudioDummyController.Default;
		}

		private void Reset()
		{
			index = 0;
			lastTime = 0;
			playingCount = 0;
		}

		public bool IsValid()
		{
			return subItems.All(t => t.Clip != null);
		}
	}
}