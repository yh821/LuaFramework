using System.Collections.Generic;

namespace Game
{
	public delegate void SignalDelegate(params object[] args);

	public sealed class SignalHandle
	{
		private LinkedList<SignalDelegate> signalList;
		private LinkedListNode<SignalDelegate> signalNode;

		internal SignalHandle(LinkedList<SignalDelegate> signalList, LinkedListNode<SignalDelegate> signalNode)
		{
			this.signalList = signalList;
			this.signalNode = signalNode;
		}

		public void Dispose()
		{
			if (signalList == null || signalNode == null) return;
			signalList.Remove(signalNode);
			signalNode = null;
			signalList = null;
		}
	}
}