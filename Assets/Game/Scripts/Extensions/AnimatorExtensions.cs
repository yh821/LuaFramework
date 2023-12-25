using System;
using System.Collections;
using System.Linq;
using Game;
using UnityEngine;

public static class AnimatorExtensions
{
	public static IEnumerator WaitEvent(this Animator animator, string evenName)
	{
		return animator.GetOrAddComponentDontSave<AnimatorEventDispatcher>().WaitEvent(evenName);
	}

	public static void WaitEvent(this Animator animator, string eventName, Action<string, AnimatorStateInfo> complete)
	{
		animator.GetOrAddComponentDontSave<AnimatorEventDispatcher>().WaitEvent(eventName, complete);
	}

	public static SignalHandle ListenEvent(this Animator animator, string eventName,
		Action<string, AnimatorStateInfo> eventDelegate)
	{
		return animator.GetOrAddComponentDontSave<AnimatorEventDispatcher>().ListenEvent(eventName, eventDelegate);
	}

	public static AnimationClip GetAnimationClip(this Animator animator, string name)
	{
		var animatorController = animator.runtimeAnimatorController;
		if (animatorController == null) return null;
		var overrideController = animatorController as AnimatorOverrideController;
		if (overrideController != null) return overrideController[name];
		return animatorController.animationClips.FirstOrDefault(clip => clip.name == name);
	}

	public static AnimatorStateListener GetStateListener(this Animator animator)
	{
		return animator.GetBehaviour<AnimatorStateListener>();
	}
}