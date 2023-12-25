using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Game
{
	[CreateAssetMenu(fileName = "AudioGroup", menuName = "Game/Audio/AudioGroup")]
	public sealed class AudioGroup : ScriptableObject
	{
		private enum EliminationMode
		{
			[EnumLabel("Skip Current Audio")] SkipCurrent,
			[EnumLabel("Stop By Left Time")] StopByLeftTime,
		}

		[SerializeField] private float interval = 0;
		[SerializeField] private int maxCount = 0;
		[SerializeField] [EnumLabel] private EliminationMode eliminationMode;
		private HashSet<IAudioController> playings = new HashSet<IAudioController>();
		private float lastTime;
		private int playingCount;
		public int PlayingCount => playingCount;

		internal bool CheckPlayableAndTryToEliminate()
		{
			if (IsPlayable()) return true;
			if (eliminationMode == EliminationMode.SkipCurrent || playings.Count == 0) return false;
			IAudioController audioCtrl = null;
			var num = float.MaxValue;
			foreach (var playing in playings)
			{
				if (playing.IsPlaying && playing.LeftTime >= 0 && playing.LeftTime < num)
				{
					num = playing.LeftTime;
					audioCtrl = playing;
				}
			}

			if (audioCtrl == null) return false;
			audioCtrl.Stop();
			return true;
		}

		internal void AddPlaying(IAudioController ctrl)
		{
			playingCount++;
			lastTime = Time.realtimeSinceStartup;
			if (eliminationMode <= 0U) return;
			playings.Add(ctrl);
		}

		internal void StopPlaying(IAudioController ctrl)
		{
			playingCount--;
			lastTime = Time.realtimeSinceStartup;
			if (eliminationMode <= 0U) return;
			playings.Remove(ctrl);
		}

		[InitializeOnLoadMethod]
		private static void EditorStartup()
		{
			EditorApplication.playmodeStateChanged += OnPlayModeStateChanged;
		}

		private static void OnPlayModeStateChanged()
		{
			foreach (var asset in AssetDatabase.FindAssets("t:AudioGroup"))
			{
				var audioGroup = AssetDatabase.LoadAssetAtPath<AudioGroup>(AssetDatabase.GUIDToAssetPath(asset));
				audioGroup.lastTime = 0;
				audioGroup.playingCount = 0;
			}
		}

		private bool IsPlayable()
		{
			return Time.realtimeSinceStartup >= lastTime + interval && (maxCount <= 0 || playingCount < maxCount);
		}
	}
}