using System;
using System.Collections.Generic;
using UnityEngine;

[DisallowMultipleComponent]
[RequireComponent(typeof(Collider))]
public sealed class Clickable : MonoBehaviour
{
	[SerializeField] private ClickableObject owner;
	private Collider[] colliders;
	private LinkedListNode<Clickable> node;

	public ClickableObject Owner
	{
		get => owner;
		set => owner = value;
	}

	public void SetClickable(bool enable)
	{
		if (colliders != null)
		{
			foreach (var collider in colliders)
			{
				collider.enabled = enable;
			}
		}
	}

	private void Awake()
	{
		colliders = GetComponents<Collider>();
		if (owner)
			node = owner.AddClickable(this);
	}

	private void OnDestroy()
	{
		if (owner != null && node != null)
			owner.RemoveClickable(node);
	}
}