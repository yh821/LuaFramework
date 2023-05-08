using UnityEngine.EventSystems;

public sealed class EventTriggerListener : EventTrigger
{
	public event EventTriggerListener.PointerEventDelegate BeginDragEvent;
	public event EventTriggerListener.PointerEventDelegate DragEvent;
	public event EventTriggerListener.PointerEventDelegate DropEvent;
	public event EventTriggerListener.PointerEventDelegate EndDragEvent;

	public event EventTriggerListener.PointerEventDelegate PointerClickEvent;
	public event EventTriggerListener.PointerEventDelegate PointerDownEvent;
	public event EventTriggerListener.PointerEventDelegate PointerEnterEvent;
	public event EventTriggerListener.PointerEventDelegate PointerExitEvent;
	public event EventTriggerListener.PointerEventDelegate PointerUpEvent;

	public event EventTriggerListener.BaseEventDelegate CancelEvent;
	public event EventTriggerListener.BaseEventDelegate SelectEvent;
	public event EventTriggerListener.BaseEventDelegate DeselectEvent;
	public event EventTriggerListener.BaseEventDelegate UpdateSelectedEvent;

	public event EventTriggerListener.AxisEventDelegate MoveEvent;


	public override void OnBeginDrag(PointerEventData eventData)
	{
		BeginDragEvent?.Invoke(eventData);
	}
	public override void OnDrag(PointerEventData eventData)
	{
		DragEvent?.Invoke(eventData);
	}
	public override void OnDrop(PointerEventData eventData)
	{
		DropEvent?.Invoke(eventData);
	}
	public override void OnEndDrag(PointerEventData eventData)
	{
		EndDragEvent?.Invoke(eventData);
	}

	public override void OnPointerClick(PointerEventData eventData)
	{
		PointerClickEvent?.Invoke(eventData);
	}
	public override void OnPointerDown(PointerEventData eventData)
	{
		PointerDownEvent?.Invoke(eventData);
	}
	public override void OnPointerEnter(PointerEventData eventData)
	{
		PointerEnterEvent?.Invoke(eventData);
	}
	public override void OnPointerExit(PointerEventData eventData)
	{
		PointerExitEvent?.Invoke(eventData);
	}
	public override void OnPointerUp(PointerEventData eventData)
	{
		PointerUpEvent?.Invoke(eventData);
	}

	public override void OnCancel(BaseEventData eventData)
	{
		CancelEvent?.Invoke(eventData);
	}
	public override void OnSelect(BaseEventData eventData)
	{
		SelectEvent?.Invoke(eventData);
	}
	public override void OnDeselect(BaseEventData eventData)
	{
		DeselectEvent?.Invoke(eventData);
	}
	public override void OnUpdateSelected(BaseEventData eventData)
	{
		UpdateSelectedEvent?.Invoke(eventData);
	}

	public override void OnMove(AxisEventData eventData)
	{
		MoveEvent?.Invoke(eventData);
	}


	public delegate void BaseEventDelegate(BaseEventData eventData);

	public delegate void PointerEventDelegate(PointerEventData eventData);

	public delegate void AxisEventDelegate(AxisEventData eventData);
}