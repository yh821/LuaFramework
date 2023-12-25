using System;
using UnityEngine;

public class AnimatorStateListener : StateMachineBehaviour
{
	public Action<int> onStateEnter;
	public Action<int> onStateExit;

	public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
	{
		base.OnStateEnter(animator, stateInfo, layerIndex);
		onStateEnter?.Invoke(stateInfo.shortNameHash);
	}

	public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
	{
		base.OnStateExit(animator, stateInfo, layerIndex);
		onStateExit?.Invoke(stateInfo.shortNameHash);
	}
}