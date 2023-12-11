using System.Collections.Generic;
using Game;
using LuaInterface;
using UnityEngine;

public class EventDispatcher : MonoBehaviour
{
	public static EventDispatcher Instance;

	private List<GameObjectAttach> enabledGameObjAttach = new List<GameObjectAttach>(256);
	private List<GameObjectAttach> disabledGameObjAttach = new List<GameObjectAttach>(256);
	private List<int> destroyedGameObjAttach = new List<int>(256);

	private List<LoadRawImage> enabledLoadRawImage = new List<LoadRawImage>(256);
	private List<LoadRawImage> disabledLoadRawImage = new List<LoadRawImage>(256);
	private List<int> destroyedLoadRawImage = new List<int>(256);

	public LuaFunction EnabledGameObjAttachFunc { get; set; }
	public LuaFunction DisabledGameObjAttachFunc { get; set; }
	public LuaFunction DestroyGameObjAttachFunc { get; set; }
	public LuaFunction EnabledLoadRawImageFunc { get; set; }
	public LuaFunction DisabledLoadRawImageFunc { get; set; }
	public LuaFunction DestroyedLoadRawImageFunc { get; set; }

	public LuaFunction ProjectileSingleEffectFunc { get; set; }
	public LuaFunction UIMouseClickEffectFunc { get; set; }

	private void Awake()
	{
		Instance = this;
	}

	private void OnDestroy()
	{
		Instance = null;
	}

	private void Update()
	{
		if (enabledGameObjAttach.Count > 0 && EnabledGameObjAttachFunc != null)
		{
			EnabledGameObjAttachFunc.Call(enabledGameObjAttach);
			enabledGameObjAttach.Clear();
		}

		if (disabledGameObjAttach.Count > 0 && DisabledGameObjAttachFunc != null)
		{
			DisabledGameObjAttachFunc.Call(disabledGameObjAttach);
			disabledGameObjAttach.Clear();
		}

		if (destroyedGameObjAttach.Count > 0 && DestroyGameObjAttachFunc != null)
		{
			DestroyGameObjAttachFunc.Call(destroyedGameObjAttach);
			destroyedGameObjAttach.Clear();
		}

		if (enabledLoadRawImage.Count > 0 && EnabledLoadRawImageFunc != null)
		{
			EnabledLoadRawImageFunc.Call(enabledLoadRawImage);
			enabledLoadRawImage.Clear();
		}

		if (disabledLoadRawImage.Count > 0 && DisabledLoadRawImageFunc != null)
		{
			DisabledLoadRawImageFunc.Call(disabledLoadRawImage);
			disabledLoadRawImage.Clear();
		}

		if (destroyedLoadRawImage.Count > 0 && DestroyedLoadRawImageFunc != null)
		{
			DestroyedLoadRawImageFunc.Call(destroyedLoadRawImage);
			destroyedLoadRawImage.Clear();
		}
	}

	public void OnGameObjAttachEnable(GameObjectAttach gameObjectAttach)
	{
		enabledGameObjAttach.Add(gameObjectAttach);
	}

	public void OnGameObjAttachDisable(GameObjectAttach gameObjectAttach)
	{
		disabledGameObjAttach.Add(gameObjectAttach);
	}

	public void OnGameObjAttachDestroy(GameObjectAttach gameObjectAttach)
	{
		destroyedGameObjAttach.Add(gameObjectAttach.GetInstanceID());
	}

	public void OnLoadRawImageEnable(LoadRawImage loadRawImage)
	{
		enabledLoadRawImage.Add(loadRawImage);
	}

	public void OnLoadRawImageDisable(LoadRawImage loadRawImage)
	{
		disabledLoadRawImage.Add(loadRawImage);
	}

	public void OnLoadRawImageDestroy(LoadRawImage loadRawImage)
	{
		destroyedLoadRawImage.Add(loadRawImage.GetInstanceID());
	}

	public void OnProjectileSingleEffect(EffectControl hitEffect, Vector3 position, Quaternion rotation,
		bool hitEffectWithRotation, Vector3 sourceScale, int layer)
	{
		ProjectileSingleEffectFunc.Call(hitEffect, position, rotation, hitEffectWithRotation, sourceScale, layer);
	}

	public void OnUIMouseClickEffect(GameObject effectInstance, GameObject[] effects, Canvas canvas,
		Transform mouseClickTransform)
	{
		UIMouseClickEffectFunc.Call(effectInstance, effects, canvas, mouseClickTransform);
	}
}