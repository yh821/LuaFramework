using System.Collections;
using UnityEngine;

namespace Game
{
	public class AudioDummyController : IAudioController
	{
		private static AudioDummyController _default;

		public static AudioDummyController Default
		{
			get
			{
				if (_default == null)
					_default = new AudioDummyController();
				return _default;
			}
		}

		internal AudioDummyController()
		{
		}

		public bool IsPlaying => false;
		public float LeftTime => 0;

		public IEnumerator WaitFinish()
		{
			return null;
		}

		public void Stop()
		{
		}

		public void SetPosition(Vector3 position)
		{
		}

		public void SetTransform(Transform transform)
		{
		}

		public void Play()
		{
		}

		public void Update()
		{
		}

		public void FinishAudio()
		{
		}
	}
}