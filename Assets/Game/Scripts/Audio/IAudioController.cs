using UnityEngine;

namespace Game
{
	public interface IAudioController : IAudioPlayer
	{
		float LeftTime { get; }
		void SetPosition(Vector3 position);
		void SetTransform(Transform transform);
		void Play();
		void Update();
		void FinishAudio();
	}
}