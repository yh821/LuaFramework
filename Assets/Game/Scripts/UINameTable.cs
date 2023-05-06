using System;
using System.Collections.Generic;
using UnityEngine;

namespace Game
{
	public class UINameTable : MonoBehaviour
	{
		[SerializeField] public List<BindPair> binds = new List<BindPair>();

		private Dictionary<string, GameObject> lookup;

		public Dictionary<string, GameObject> Lookup
		{
			get
			{
				if (lookup == null)
				{
					lookup = new Dictionary<string, GameObject>(StringComparer.Ordinal);
					if (binds != null)
					{
						foreach (var bind in binds)
							lookup.Add(bind.Name, bind.Widget);
					}
				}

				return lookup;
			}
		}

		public GameObject Find(string name)
		{
			return Lookup.TryGetValue(name, out var gameObject) ? gameObject : null;
		}

		public bool Add(string name, GameObject go)
		{
			if (lookup.ContainsKey(name))
				return false;
			lookup.Add(name, go);
			binds.Add(new BindPair {Name = name, Widget = go});
			return true;
		}

		public void Sort()
		{
			binds.Sort((a, b) => string.Compare(a.Name, b.Name, StringComparison.Ordinal));
		}

		public BindPair[] Search(string name)
		{
			var list = new List<BindPair>();
			foreach (var bind in binds)
			{
				if (bind.Name.StartsWith(name))
					list.Add(bind);
			}

			return list.ToArray();
		}

		[Serializable]
		public struct BindPair
		{
			public string Name;
			public GameObject Widget;
		}
	}
}