using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Game
{
	public sealed class GridView : ListView
	{
		public enum ScrollDirectionEnum
		{
			Horizontal,
			Vertical,
		}

		public enum FillDirectionEnum
		{
			Forward,
			Reverse,
		}

		[SerializeField] private int arrangeCount = 1;
		[SerializeField] private float snapSpeed = 5;
		[SerializeField] private ScrollDirectionEnum scrollDirection;
		[SerializeField] private FillDirectionEnum fillDirection;
		[SerializeField] private bool snapping;
		public Vector2 spacing;
		public Vector2 cellSize;

		protected override Vector2 CalculateContentSize(int cellCount)
		{
			var num1 = Mathf.CeilToInt((float) cellCount / arrangeCount);
			float num2, num3, num4, num5;
			if (scrollDirection == ScrollDirectionEnum.Horizontal)
			{
				num2 = cellSize.x * num1;
				num3 = cellSize.y * arrangeCount;
				num4 = num1 - 1;
				num5 = arrangeCount - 1;
			}
			else
			{
				num2 = cellSize.x * arrangeCount;
				num3 = cellSize.y * num1;
				num4 = arrangeCount - 1;
				num5 = num1 - 1;
			}

			return new Vector2(num2 + spacing.x * num4, num3 + spacing.y * num5);
		}

		protected override void CalculateCurrentActiveCellRange(
			Vector2 scrollPosition,
			out int startIndex,
			out int endIndex)
		{
			var rect1 = ScrollContent.rect;
			var rect2 = ScrollView.rect;
			if (scrollDirection == ScrollDirectionEnum.Horizontal)
			{
				var num1 = rect1.width - rect2.width;
				var num2 = scrollPosition.x * num1;
				startIndex = GetCellIndexByPositionXStart(num2);
				endIndex = GetCellIndexByPositionXEnd(num2 + rect2.width);
			}
			else
			{
				var num1 = rect1.height - rect2.height;
				var num2 = scrollPosition.y * num1;
				var num3 = num2 + rect2.height;
				startIndex = GetCellIndexByPositionYStart(rect1.height - num3);
				endIndex = GetCellIndexByPositionYEnd(rect1.height - num2);
			}
		}

		protected override void LayoutCell(GameObject cell, int index)
		{
			var num1 = index / arrangeCount;
			var num2 = fillDirection == FillDirectionEnum.Forward
				? index % arrangeCount
				: arrangeCount - index % arrangeCount;
			var rectTrans = (RectTransform) cell.transform;
			rectTrans.anchorMin = Vector2.zero;
			rectTrans.anchorMax = Vector2.zero;
			rectTrans.sizeDelta = cellSize;
			if (scrollDirection == ScrollDirectionEnum.Horizontal)
			{
				rectTrans.pivot = Vector2.zero;
				rectTrans.anchoredPosition = new Vector2(num1 * (cellSize.x + spacing.x),
					num2 * (cellSize.y + spacing.y));
			}
			else
			{
				var sizeDelta = ScrollRect.content.sizeDelta;
				rectTrans.pivot = new Vector2(0, 1);
				rectTrans.anchoredPosition = new Vector2(num2 * (cellSize.x + spacing.x),
					sizeDelta.y - num1 * (cellSize.y + spacing.y));
			}
		}

		protected override Vector2 GetCellPositionByIndex(int index)
		{
			var num1 = index / arrangeCount;
			var num2 = index % arrangeCount;
			return scrollDirection == ScrollDirectionEnum.Horizontal
				? new Vector2(num1 * (cellSize.x + spacing.x), num2 * (cellSize.y + spacing.y))
				: new Vector2(num2 * (cellSize.x + spacing.x), num1 * (cellSize.y + spacing.y));
		}

		protected override void UpdateSnapping()
		{
			if (!snapping) return;
			var scrollContent = ScrollContent;
			var rect1 = scrollContent.rect;
			var rect2 = ScrollView.rect;
			var normalizedPosition = ScrollRect.normalizedPosition;
			if (scrollDirection == ScrollDirectionEnum.Horizontal)
			{
				var num1 = rect1.width - rect2.width;
				var cellPositionByIndex = GetCellPositionByIndex(
					Mathf.RoundToInt(GetCellIndexByPositionXStart(normalizedPosition.x * num1 + cellSize.x / 2)));
				var num2 = num1 / 2 - cellPositionByIndex.x;
				var anchoredPosition = scrollContent.anchoredPosition;
				if (Mathf.Abs(num2 - anchoredPosition.x) > 0.0299999993294477 * snapSpeed)
				{
					var x = Mathf.Lerp(anchoredPosition.x, num2, Time.deltaTime * snapSpeed);
					scrollContent.anchoredPosition = new Vector2(x, anchoredPosition.y);
				}
				else
					scrollContent.anchoredPosition = new Vector2(num2, anchoredPosition.y);
			}
			else
			{
				var num1 = rect1.height - rect2.height;
				var cellPositionByIndex = GetCellPositionByIndex(
					Mathf.RoundToInt(GetCellIndexByPositionXStart(normalizedPosition.y * num1 + cellSize.y / 2)));
				var num2 = num1 / 2 - cellPositionByIndex.y;
				var anchoredPosition = scrollContent.anchoredPosition;
				if (Mathf.Abs(num2 - anchoredPosition.y) > 0.0299999993294477 * snapSpeed)
				{
					var y = Mathf.Lerp(anchoredPosition.y, num2, Time.deltaTime * snapSpeed);
					scrollContent.anchoredPosition = new Vector2(anchoredPosition.x, y);
				}
				else
					scrollContent.anchoredPosition = new Vector2(anchoredPosition.x, num2);
			}
		}

		private int GetCellIndexByPositionXStart(float position)
		{
			return Mathf.FloorToInt((position + spacing.x) / (cellSize.x + spacing.x)) * arrangeCount;
		}

		private int GetCellIndexByPositionXEnd(float position)
		{
			return Mathf.FloorToInt((position + spacing.x * 0.5f) / (cellSize.x + spacing.x) + 1) * arrangeCount;
		}

		private int GetCellIndexByPositionYStart(float position)
		{
			return Mathf.FloorToInt((position + spacing.y) / (cellSize.y + spacing.y)) * arrangeCount;
		}

		private int GetCellIndexByPositionYEnd(float position)
		{
			return Mathf.FloorToInt((position + spacing.y * 0.5f) / (cellSize.y + spacing.y) + 1) * arrangeCount;
		}
	}
}