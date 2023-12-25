using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace Game
{
	[CustomPropertyDrawer(typeof(EnumMaskAttribute))]
	public sealed class EnumMaskDrawer : PropertyDrawer
	{
		public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
		{
			if (property.propertyType != SerializedPropertyType.Enum) return;
			var fields = fieldInfo.FieldType.GetFields(BindingFlags.Static | BindingFlags.Public);
			var displayOptions = new string[fields.Length];
			Array.Copy(property.enumNames, displayOptions, fields.Length);
			for (int i = 0; i < fields.Length; i++)
			{
				var customAttrs =
					(EnumLabelAttribute[]) fields[i].GetCustomAttributes(typeof(EnumLabelAttribute), false);
				if (customAttrs.Length > 0U)
					displayOptions[i] = customAttrs[0].Label;
			}

			EditorGUI.BeginProperty(position, label, property);
			property.intValue = EditorGUI.MaskField(position, label, property.intValue, displayOptions);
			EditorGUI.EndProperty();
		}
	}
}