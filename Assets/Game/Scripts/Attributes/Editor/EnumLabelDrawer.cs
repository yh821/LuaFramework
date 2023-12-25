using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Game
{
	[CustomPropertyDrawer(typeof(EnumLabelAttribute))]
	public sealed class EnumLabelDrawer : PropertyDrawer
	{
		private Dictionary<string, string> customEnumNames = new Dictionary<string, string>();

		public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
		{
			if (property.propertyType != SerializedPropertyType.Enum) return;
			var attr = (EnumLabelAttribute) this.attribute;
			SetupCustomEnumNames(property, property.enumNames);
			EditorGUI.BeginChangeCheck();
			var array = property.enumNames.Where(enumName => customEnumNames.ContainsKey(enumName))
				.Select(enumName => customEnumNames[enumName]).ToArray();
			var numArray = GetIndexArray(attr.EnumOrder);
			if (numArray.Length != array.Length)
			{
				numArray = new int[array.Length];
				for (var i = 0; i < numArray.Length; i++)
					numArray[i] = i;
			}

			var displayOptions = new string[array.Length];
			displayOptions[0] = array[0];
			for (int i = 0; i < array.Length; i++)
				displayOptions[i] = array[numArray[i]];
			var selectIndex = -1;
			for (int i = 0; i < numArray.Length; i++)
			{
				if (numArray[i] == property.enumValueIndex)
				{
					selectIndex = i;
					break;
				}
			}

			if (selectIndex == -1 && property.enumValueIndex != -1)
				SortingError(position, property, label);
			else
			{
				var label1 = property.displayName;
				if (!string.IsNullOrEmpty(attr.Label))
					label1 = attr.Label;
				var index = EditorGUI.Popup(position, label1, selectIndex, displayOptions);
				if (!EditorGUI.EndChangeCheck() || index < 0) return;
				property.enumValueIndex = numArray[index];
			}
		}

		private void SetupCustomEnumNames(SerializedProperty property, string[] enumNames)
		{
			var fieldType = fieldInfo.FieldType;
			foreach (var customAttr in fieldInfo.GetCustomAttributes(typeof(EnumLabelAttribute), false))
			{
				foreach (var enumName in enumNames)
				{
					if (customEnumNames.ContainsKey(enumName)) continue;
					var field = fieldType.GetField(enumName);
					if (field == null) continue;
					var customAttrs = field.GetCustomAttributes(customAttr.GetType(), false);
					foreach (EnumLabelAttribute attr in customAttrs)
						customEnumNames.Add(enumName, attr.Label);
				}
			}
		}

		private int[] GetIndexArray(int[] order)
		{
			var numArray = new int[order.Length];
			for (var i = 0; i < order.Length; i++)
				numArray[i] = order.Count(t => order[i] > t);
			return numArray;
		}

		private void SortingError(Rect position, SerializedProperty property, GUIContent label)
		{
			EditorGUI.PropertyField(position, property, new GUIContent(label.text + " (sorting error)"));
			EditorGUI.EndProperty();
		}
	}
}