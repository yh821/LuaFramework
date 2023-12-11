using System;
using System.Collections.Generic;

public static class DictionaryExtension
{
	public static void RemoveAll<K, V>(this Dictionary<K, V> dict, Func<K, V, bool> filter)
	{
		var sweepList = RemoveList<K>.SweepList;
		using var enumerator = dict.GetEnumerator();
		while (enumerator.MoveNext())
		{
			var current = enumerator.Current;
			if (filter(current.Key, current.Value))
				sweepList.Add(current.Key);
		}
		foreach (var item in sweepList)
			dict.Remove(item);
		sweepList.Clear();
	}

	private static class RemoveList<T>
	{
		private static readonly List<T> _sweepList = new List<T>();
		public static List<T> SweepList => _sweepList;
	}
}