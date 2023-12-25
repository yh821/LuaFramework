using System.Collections.Generic;

namespace Game
{
	public sealed class Signal
	{
		private LinkedList<SignalDelegate> signalDelegates;

		internal void Clear()
		{
			signalDelegates?.Clear();
		}

		internal SignalHandle Add(SignalDelegate callback)
		{
			if (signalDelegates == null)
				signalDelegates = new LinkedList<SignalDelegate>();
			return new SignalHandle(signalDelegates, signalDelegates.AddLast(callback));
		}

		internal void Invoke(params object[] args)
		{
			if (signalDelegates == null) return;
			LinkedListNode<SignalDelegate> next;
			for (LinkedListNode<SignalDelegate> linkedListNode = signalDelegates.First;
				linkedListNode != null;
				linkedListNode = next)
			{
				next = linkedListNode.Next;
				linkedListNode.Value(args);
			}
		}
	}
}