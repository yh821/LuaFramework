using UnityEngine.Events;
using UnityEngine.UI;

public static class ButtonExtension
{
	public static void SetClickListener(this Button button, UnityAction callback)
	{
		button.onClick.RemoveAllListeners();
		button.onClick.AddListener(callback);
	}

	public static void AddClickListener(this Button button, UnityAction callback)
	{
		button.onClick.RemoveAllListeners();
		button.onClick.AddListener(callback);
	}
}