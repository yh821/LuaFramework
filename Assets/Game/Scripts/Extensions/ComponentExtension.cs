using System;
using UnityEngine;

public static class ComponentExtension
{
	public static Component GetOrAddComponent(this Component com, Type type)
	{
		var component = com.GetComponent(type);
		if (component == null)
			component = com.gameObject.AddComponent(type);
		return component;
	}

	public static Component GetOrAddComponent<T>(this Component com, Type type) where T : Component
	{
		var component = com.GetComponent<T>();
		if (component == null)
			component = com.gameObject.AddComponent<T>();
		return component;
	}

}