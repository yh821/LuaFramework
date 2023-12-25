using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace Game
{
	[RequireComponent(typeof(ScrollRect))]
	public abstract class ListView : MonoBehaviour, IBeginDragHandler, IEndDragHandler, IEventSystemHandler
	{
		private struct CellData
		{
			public GameObject Cell { get; set; }
			public int Index { get; set; }
		}

		public delegate GameObject GetCellDelegate(int index);

		public delegate int CellCountDelegate();

		public delegate Vector2 GetCellSizeDelegate(int index);

		public delegate void RecycleCellDelegate(int index, GameObject go);

		private readonly List<CellData> _activeCells = new List<CellData>();
		private bool _dragging = false;
		private int _jumpIndex = -1;
		private float _jumpOffset = 0;
		private float _jumpSpeed = 0;
		private ScrollRect _scrollRect;
		private bool _refreshSize;
		private bool _refreshData;
		private Action _refreshCallBack;
		private bool _refreshActive;
		private int _activeCellsStartIndex;
		private int _activeCellsEndIndex;

		internal ListView()
		{
		}

		public GetCellDelegate GetCellDlg { get; set; }
		public CellCountDelegate CellCountDlg { get; set; }
		public GetCellSizeDelegate GetCellSizeDlg { get; set; }
		public RecycleCellDelegate RecycleCellDlg { get; set; }

		public int ActiveCellsStartIndex => _activeCellsStartIndex;
		public int ActiveCellsEndIndex => _activeCellsEndIndex;
		public bool IsJumping => _jumpIndex > 0;

		public GameObject[] ActiveCells
		{
			get
			{
				_activeCells.Sort((a, b) => a.Index.CompareTo(b.Index));
				var gameObjectArray = new GameObject[_activeCells.Count];
				for (int index = 0; index < gameObjectArray.Length; index++)
					gameObjectArray[index] = _activeCells[index].Cell;
				return gameObjectArray;
			}
		}

		protected ScrollRect ScrollRect
		{
			get
			{
				if (_scrollRect == null)
					_scrollRect = GetComponent<ScrollRect>();
				return _scrollRect;
			}
		}

		protected RectTransform ScrollView => ScrollRect.viewport;
		protected RectTransform ScrollContent => ScrollRect.content;
		protected int CellCount { get; private set; }

		public void OnBeginDrag(PointerEventData eventData)
		{
			_dragging = true;
		}

		public void OnEndDrag(PointerEventData eventData)
		{
			_dragging = false;
		}

		public void Reload(Action callback = null)
		{
			_refreshSize = true;
			_refreshData = true;
			_refreshCallBack = callback;
		}

		public void JumpToIndex(int index, float offset = 0, float speed = -1)
		{
			_jumpIndex = index;
			_jumpOffset = offset;
			_jumpSpeed = speed;
		}

		protected abstract Vector2 CalculateContentSize(int cellCount);

		protected abstract void CalculateCurrentActiveCellRange(
			Vector2 scrollPosition,
			out int startIndex,
			out int endIndex);

		protected abstract void LayoutCell(GameObject cell, int index);

		protected abstract Vector2 GetCellPositionByIndex(int index);

		protected virtual void UpdateCell(GameObject cell, int index)
		{
		}

		protected virtual void UpdateSnapping()
		{
		}

		protected void OnEnable()
		{
			ScrollRect.onValueChanged.AddListener(OnScrollRectValueChanged);
		}

		protected void OnDisable()
		{
			ScrollRect.onValueChanged.RemoveListener(OnScrollRectValueChanged);
		}

		protected void OnValidate()
		{
			_refreshActive = true;
		}

		private void Update()
		{
			DoRefreshSize();
			if (_jumpIndex >= 0)
			{
				if (CellCount > 0)
					UpdateJumping();
			}
			else if (!_dragging)
				UpdateSnapping();

			DoRefresh();
		}

		private void LateUpdate()
		{
			DoRefreshSize();
			if (_jumpIndex >= 0 && _jumpSpeed <= 0)
				UpdateJumping();
			DoRefresh();
		}

		private void UpdateJumping()
		{
			_jumpIndex = Mathf.Clamp(_jumpIndex, 0, CellCount - 1);
			var cellPositionIndex = GetCellPositionByIndex(_jumpIndex);
			var rect1 = ScrollContent.rect;
			var rect2 = ScrollView.rect;
			var num1 = rect1.width - rect2.width;
			var num2 = rect1.height - rect2.height;
			var scrollRect = ScrollRect;
			var normalizedPosition1 = scrollRect.normalizedPosition;
			if (num1 > 0)
			{
				var num3 = cellPositionIndex.x + _jumpOffset;
				normalizedPosition1.x = num3 / num1;
			}

			if (num2 > 0)
			{
				var num3 = cellPositionIndex.y + _jumpOffset;
				normalizedPosition1.y = 1 - num3 / num2;
			}

			if (_jumpSpeed > 0)
			{
				var normalizedPosition2 = scrollRect.normalizedPosition;
				var f1 = normalizedPosition1.x - normalizedPosition2.x;
				var f2 = Mathf.Sign(f1) * _jumpSpeed * Time.deltaTime;
				if (Mathf.Abs(f2) < Mathf.Abs(f1))
				{
					normalizedPosition2.x += f2;
					scrollRect.normalizedPosition = normalizedPosition2;
				}
				else
				{
					scrollRect.normalizedPosition = normalizedPosition1;
					_jumpIndex = -1;
				}
			}
			else
			{
				scrollRect.normalizedPosition = normalizedPosition1;
				_jumpIndex = -1;
			}
		}

		private void DoRefreshSize()
		{
			if (!_refreshSize) return;
			CellCount = CellCountDlg();
			var contentSize = CalculateContentSize(CellCount);
			var viewport = ScrollView;
			if (viewport != null)
			{
				contentSize.x = Mathf.Max(contentSize.x, viewport.rect.width);
				contentSize.y = Mathf.Max(contentSize.y, viewport.rect.height);
			}

			var content = ScrollContent;
			content.anchorMin = new Vector2(0.5f, 0.5f);
			content.anchorMax = new Vector2(0.5f, 0.5f);
			content.pivot = new Vector2(0.5f, 0.5f);
			content.sizeDelta = contentSize;
			_refreshSize = false;
		}

		private void DoRefresh()
		{
			if (_refreshData)
			{
				RefreshData();
				_refreshData = false;
				_refreshActive = false;
				_refreshCallBack?.Invoke();
				_refreshCallBack = null;
			}
			else
			{
				if (!_refreshActive) return;
				RefreshActive();
				_refreshActive = false;
			}
		}

		private void OnScrollRectValueChanged(Vector2 arg)
		{
			_refreshActive = true;
		}

		private void RefreshActive()
		{
			CalculateCurrentActiveCellRange(ScrollRect.normalizedPosition, out var startIndex1, out var endIndex1);
			var startIndex2 = Mathf.Clamp(startIndex1, 0, CellCount);
			var endIndex2 = Mathf.Clamp(endIndex1, 0, CellCount);
			if (startIndex2 != _activeCellsEndIndex || endIndex2 != _activeCellsEndIndex)
				ResetVisibleCells(startIndex2, endIndex2);
			foreach (var cell in _activeCells)
				UpdateCell(cell.Cell, cell.Index);
		}

		private void ResetVisibleCells(int startIndex, int endIndex)
		{
			_activeCells.RemoveAll(cellData =>
			{
				var index = cellData.Index;
				if (index >= startIndex && index < endIndex) return false;
				cellData.Cell.transform.localPosition = Vector3.zero;
				cellData.Cell.transform.localRotation = Quaternion.identity;
				cellData.Cell.transform.localScale = Vector3.one;
				if (RecycleCellDlg != null)
					RecycleCellDlg(cellData.Index, cellData.Cell);
				else
					Singleton<GameObjectPool>.Instance.Free(cellData.Cell);
				return true;
			});
			var scrollRect = ScrollRect;
			for (var index = startIndex; index < endIndex; index++)
			{
				var flag = _activeCells.Any(data => data.Index == index);
				if (flag) continue;

				var cell = GetCellDlg(index);
				cell.transform.SetParent(scrollRect.content, false);
				LayoutCell(cell, index);
				_activeCells.Add(new CellData()
				{
					Cell = cell,
					Index = index
				});
			}

			_activeCellsStartIndex = startIndex;
			_activeCellsEndIndex = endIndex;
		}

		private void RefreshData()
		{
			CalculateCurrentActiveCellRange(ScrollRect.normalizedPosition, out var startIndex, out var endIndex);
			var startIndex1 = Mathf.Clamp(startIndex, 0, CellCount);
			var endIndex1 = Mathf.Clamp(endIndex, 0, CellCount);
			foreach (var cell in _activeCells)
			{
				if (RecycleCellDlg != null)
					RecycleCellDlg(cell.Index, cell.Cell);
				else
					Singleton<GameObjectPool>.Instance.Free(cell.Cell);
			}

			var scrollRect = ScrollRect;
			for (var index = startIndex1; index < endIndex1; index++)
			{
				var cell = GetCellDlg(index);
				cell.transform.SetParent(scrollRect.content, false);
				LayoutCell(cell, index);
				_activeCells.Add(new CellData()
				{
					Cell = cell,
					Index = index
				});
			}

			_activeCellsStartIndex = startIndex1;
			_activeCellsEndIndex = endIndex1;
			foreach (var cell in _activeCells)
				UpdateCell(cell.Cell, cell.Index);
		}
	}
}