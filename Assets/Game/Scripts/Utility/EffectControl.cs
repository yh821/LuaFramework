using System;
using UnityEngine;

namespace Game
{
	public sealed class EffectControl : MonoBehaviour
	{
		private enum PlayState
		{
			Stopping,
			Pending,
			Playing,
			Pausing,
			Fadeout,
		}

		[SerializeField] private bool looping = false;
		[SerializeField] private bool noScalable = false;
		[SerializeField] private float delay = 0;
		[SerializeField] private float duration = 5f;
		[SerializeField] private float fadeout = 1f;

		private PlayState state = PlayState.Stopping;
		private float playbackSpeed = 1f;
		private float exitesTime = 0;
		private float timer;
		private ParticleSystem[] _particleSystems;
		private Animator[] _animators;
		private Animation[] _animations;

		public event Action FadeoutEvent;
		public event Action FinishEvent;

		public bool IsLooping
		{
			get => looping;
			set => looping = value;
		}

		public float Duration
		{
			get => duration;
			set => duration = value;
		}

		public float Fadeout
		{
			get => fadeout;
			set => fadeout = value;
		}

		public bool IsPaused => state == PlayState.Pausing;
		public bool IsStopped => state == PlayState.Stopping;
		public bool IsNoScalable => noScalable;

		private ParticleSystem[] ParticleSystems
		{
			get
			{
				if (_particleSystems == null)
				{
					_particleSystems = GetComponentsInChildren<ParticleSystem>(true);
				}

				return _particleSystems;
			}
		}

		private Animator[] Animators
		{
			get
			{
				if (_animators == null)
				{
					_animators = GetComponentsInChildren<Animator>(true);
					foreach (var animator in _animators)
						animator.speed = playbackSpeed;
				}

				return _animators;
			}
		}

		private Animation[] Animations
		{
			get
			{
				if (_animations == null)
				{
					_animations = GetComponentsInChildren<Animation>(true);
					foreach (var animation in _animations)
					{
						var clip = animation.clip;
						if (clip != null)
							animation[clip.name].speed = playbackSpeed;
					}
				}

				return _animations;
			}
		}

		public void WaitFinish(Action callback)
		{
			FinishEvent = callback;
			if (!IsLooping) return;
			Debug.LogErrorFormat("该特效已设置循环，Finish不会回调。可能造成内存泄露：{0}", gameObject.name);
		}

		public float PlaybackSpeed
		{
			get => playbackSpeed;
			set
			{
				playbackSpeed = value;
				foreach (var animator in _animators)
					animator.speed = playbackSpeed;
				foreach (var animation in _animations)
				{
					var clip = animation.clip;
					if (clip != null)
						animation[clip.name].speed = playbackSpeed;
				}
			}
		}
	}
}