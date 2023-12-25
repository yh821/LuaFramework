using System;
using System.Collections.Generic;

public static class ArrayExtension
{
	public static void Shuffle<T>(this T[] array)
	{
		for (int i1 = 0; i1 < array.Length; i1++)
		{
			var i2 = UnityEngine.Random.Range(0, array.Length);
			var obj = array[i2];
			array[i2] = array[i1];
			array[i1] = obj;
		}
	}

	public static T[] RemoveDuplicate<T>(this T[] array)
	{
		var objSet = new HashSet<T>();
		foreach (var obj in array)
		{
			if (!objSet.Contains(obj))
				objSet.Add(obj);
		}

		var objArray = new T[objSet.Count];
		var num = 0;
		foreach (var obj in objSet)
			objArray[num++] = obj;
		return objArray;
	}

	public static U[] Cast<T, U>(this T[] array)
		where T : class
		where U : class, T
	{
		return Array.ConvertAll(array, input => input as U);
	}
}