using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Game
{
	public class Singleton<T> where T : class, new()
	{
		private static T _instance = default(T);

		public static T Instance
		{
			get { return _instance ??= new T(); }
		}
	}
}