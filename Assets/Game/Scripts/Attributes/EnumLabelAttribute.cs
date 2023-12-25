using System;
using UnityEngine;

namespace Game
{
	[AttributeUsage(AttributeTargets.Enum | AttributeTargets.Field)]
	public class EnumLabelAttribute : PropertyAttribute
	{
		private int[] enumOrder = new int[0];
		private string label;

		public EnumLabelAttribute()
		{
		}

		public EnumLabelAttribute(string label)
		{
			this.label = label;
		}


		public EnumLabelAttribute(string label, params int[] enumOrder)
		{
			this.label = label;
			this.enumOrder = enumOrder;
		}

		public string Label => label;

		public int[] EnumOrder => enumOrder;
	}
}