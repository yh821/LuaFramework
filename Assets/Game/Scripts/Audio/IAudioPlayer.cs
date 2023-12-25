using System.Collections;

namespace Game
{
	public interface IAudioPlayer
	{
		bool IsPlaying { get; }
		IEnumerator WaitFinish();
		void Stop();
	}
}