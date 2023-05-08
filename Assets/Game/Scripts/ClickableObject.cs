using System;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;

[DisallowMultipleComponent]
public sealed class ClickableObject : MonoBehaviour
{
	private LinkedList<Clickable> clickables = new LinkedList<Clickable>();
	private bool clickable = true;
	private Action clickListener;

	public void SetClickListener(Action listener)
	{
		clickListener = listener;
	}

	public void SetClickable(bool enable)
	{
		clickable = enable;
		foreach (var click in clickables)
		{
			click.SetClickable(enable);
		}
	}

	[NoToLua]
	public void TriggerClick()
	{
		clickListener?.Invoke();
	}

	[NoToLua]
	public LinkedListNode<Clickable> AddClickable(Clickable clickable)
	{
		clickable.SetClickable(this.clickable);
		return clickables.AddLast(clickable);
	}

	[NoToLua]
	public void RemoveClickable(LinkedListNode<Clickable> node)
	{
		clickables.Remove(node);
	}
}