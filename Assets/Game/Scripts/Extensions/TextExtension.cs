using System;
using DG.Tweening;
using UnityEngine.UI;

public static class TextExtension
{
	public static Tweener DoNumberTo(this Text text, int from, int to, float duration, Action complete)
	{
		Tweener t = DOTween.To(() => from, x => from = x, to, duration);
		t.OnUpdate(() =>
		{
			if (text != null) text.text = from.ToString();
		});
		t.OnComplete(() => { complete?.Invoke(); });
		return t;
	}

	public static Tweener DoFloatNumberTo(this Text text, float from, float to, float duration, Action complete,
		Action<float> onUpdate)
	{
		Tweener t = DOTween.To(() => from, x => from = x, to, duration);
		t.OnUpdate(() => { onUpdate?.Invoke(from); });
		t.OnComplete(() => { complete?.Invoke(); });
		return t;
	}
}