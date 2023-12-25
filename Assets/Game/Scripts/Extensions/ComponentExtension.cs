using System;
using UnityEngine;
using UnityEngine.Assertions;

public static class ComponentExtension
{
	public static Component GetOrAddComponent(this Component com, Type type)
	{
		var component = com.GetComponent(type);
		if (component == null)
			component = com.gameObject.AddComponent(type);
		return component;
	}

	public static T GetOrAddComponent<T>(this Component com) where T : Component
	{
		var component = com.GetComponent<T>();
		if (component == null)
			component = com.gameObject.AddComponent<T>();
		return component;
	}

	public static Component GetOrAddComponentDontSave(this Component com, Type type)
	{
		var component = com.GetComponent(type);
		if (component == null)
		{
			component = com.gameObject.AddComponent(type);
			component.hideFlags = HideFlags.DontSave;
		}

		return component;
	}

	public static T GetOrAddComponentDontSave<T>(this Component com) where T : Component
	{
		var component = com.GetComponent<T>();
		if (component == null)
		{
			component = com.gameObject.AddComponent<T>();
			component.hideFlags = HideFlags.DontSave;
		}

		return component;
	}

	public static bool HasComponent(this Component com, Type type)
	{
		return com.GetComponent(type) != null;
	}

	public static bool HasComponent<T>(this Component com) where T : Component
	{
		return com.GetComponent<T>() != null;
	}

	public static T GetComponentInParentHard<T>(this Component com) where T : Component
	{
		Assert.IsNotNull(com);
		for (var trans = com.transform; trans != null; trans = trans.parent)
		{
			var component = trans.GetComponent<T>();
			if (component != null)
				return component;
		}

		return default;
	}
}