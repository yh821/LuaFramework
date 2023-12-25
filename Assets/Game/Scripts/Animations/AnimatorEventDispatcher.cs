using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;

namespace Game
{
	[DisallowMultipleComponent]
	public sealed class AnimatorEventDispatcher : MonoBehaviour
	{
		private Dictionary<string, Signal> eventTable = new Dictionary<string, Signal>(32, StringComparer.Ordinal);

		public IEnumerator WaitEvent(string eventName)
		{
			var finished = false;
			SignalHandle handle = null;
			handle = ListenEvent(eventName, (param, info) =>
			{
				finished = true;
				handle?.Dispose();
			});
			return new WaitUntil(() => finished);
		}

		public void WaitEvent(string eventName, Action<string, AnimatorStateInfo> complete)
		{
			Assert.IsNotNull(complete);
			SignalHandle handle = null;
			handle = ListenEvent(eventName, (param, info) =>
			{
				complete(param, info);
				handle?.Dispose();
			});
		}

		public SignalHandle ListenEvent(string eventName, Action<string, AnimatorStateInfo> eventDelegate)
		{
			if (!eventTable.TryGetValue(eventName, out var signal))
			{
				signal = new Signal();
				eventTable.Add(eventName, signal);
			}

			return signal.Add(args => eventDelegate((string) args[0], (AnimatorStateInfo) args[1]));
		}

		internal void DispatchEvent(string eventName, string param, AnimatorStateInfo info)
		{
			if (!eventTable.TryGetValue(eventName, out var signal)) return;
			signal.Invoke(param, info);
		}
	}
}