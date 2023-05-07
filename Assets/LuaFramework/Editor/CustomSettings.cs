using UnityEngine;
using System;
using System.Collections.Generic;
using LuaInterface;
using LuaFramework;
using UnityEditor;
using BindType = ToLuaMenu.BindType;
using UnityEngine.UI;
using System.Reflection;
using DG.Tweening;
using Game;
using HedgehogTeam.EasyTouch;

public static class CustomSettings
{
	public static string FrameworkPath = AppConst.FrameworkRoot;
	public static string saveDir = FrameworkPath + "/ToLua/Source/Generate/";
	public static string luaDir = FrameworkPath + "/Lua/";
	public static string toluaBaseType = FrameworkPath + "/ToLua/BaseType/";
	public static string baseLuaDir = FrameworkPath + "/ToLua/Lua";
	public static string injectionFilesPath = Application.dataPath + "/ToLua/Injection/";

	//导出时强制做为静态类的类型(注意customTypeList 还要添加这个类型才能导出)
	//unity 有些类作为sealed class, 其实完全等价于静态类
	public static List<Type> staticClassTypes = new List<Type>
	{
		typeof(Application),
		typeof(Time),
		typeof(Screen),
		typeof(SleepTimeout),
		typeof(Input),
		typeof(Resources),
		typeof(Physics),
		typeof(RenderSettings),
		typeof(QualitySettings),
		typeof(GL),
		typeof(Graphics),
	};

	//附加导出委托类型(在导出委托时, customTypeList 中牵扯的委托类型都会导出， 无需写在这里)
	public static DelegateType[] customDelegateList =
	{
		_DT(typeof(Action)),
		_DT(typeof(UnityEngine.Events.UnityAction)),
		_DT(typeof(Predicate<int>)),
		_DT(typeof(Action<int>)),
		_DT(typeof(Comparison<int>)),
		_DT(typeof(Func<int, int>)),
	};

	//在这里添加你要导出注册到lua的类型列表
	public static BindType[] customTypeList =
	{
		//------------------------为例子导出--------------------------------
		//_GT(typeof(TestEventListener)),
		//_GT(typeof(TestProtol)),
		//_GT(typeof(TestAccount)),
		//_GT(typeof(Dictionary<int, TestAccount>)).SetLibName("AccountMap"),
		//_GT(typeof(KeyValuePair<int, TestAccount>)),
		//_GT(typeof(Dictionary<int, TestAccount>.KeyCollection)),
		//_GT(typeof(Dictionary<int, TestAccount>.ValueCollection)),
		//_GT(typeof(TestExport)),
		//_GT(typeof(TestExport.Space)),
		//-------------------------------------------------------------------

		_GT(typeof(LuaInjectionStation)),
		_GT(typeof(InjectType)),
		_GT(typeof(Debugger)).SetNameSpace(null),

		#region DOTween

		_GT(typeof(DOTween)),
		_GT(typeof(Tween)).SetBaseType(typeof(System.Object)).AddExtendType(typeof(TweenExtensions)),
		_GT(typeof(Sequence)).AddExtendType(typeof(TweenSettingsExtensions)),
		_GT(typeof(Tweener)).AddExtendType(typeof(TweenSettingsExtensions)),
		_GT(typeof(LoopType)),
		_GT(typeof(PathMode)),
		_GT(typeof(PathType)),
		_GT(typeof(RotateMode)),
		_GT(typeof(Component)).AddExtendType(typeof(ComponentExtension)).AddExtendType(typeof(ShortcutExtensions)),
		_GT(typeof(Transform)).AddExtendType(typeof(ShortcutExtensions)),
		_GT(typeof(Light)).AddExtendType(typeof(ShortcutExtensions)),
		_GT(typeof(Material)).AddExtendType(typeof(ShortcutExtensions)),
		_GT(typeof(Rigidbody)).AddExtendType(typeof(ShortcutExtensions)),
		_GT(typeof(Camera)).AddExtendType(typeof(ShortcutExtensions)),
		_GT(typeof(AudioSource)).AddExtendType(typeof(ShortcutExtensions)),
		//_GT(typeof(LineRenderer)).AddExtendType(typeof(ShortcutExtensions)),
		//_GT(typeof(TrailRenderer)).AddExtendType(typeof(ShortcutExtensions)),

		#endregion

		_GT(typeof(Behaviour)),
		_GT(typeof(MonoBehaviour)),
		_GT(typeof(GameObject)),
		_GT(typeof(TrackedReference)),
		_GT(typeof(Application)),
		_GT(typeof(Physics)),
		_GT(typeof(Collider)),
		_GT(typeof(Time)),
		_GT(typeof(Texture)),
		_GT(typeof(Texture2D)),
		_GT(typeof(Shader)),
		_GT(typeof(Renderer)),
		_GT(typeof(WWW)),
		_GT(typeof(Screen)),
		_GT(typeof(CameraClearFlags)),
		_GT(typeof(AudioClip)),
		_GT(typeof(AssetBundle)),
		//_GT(typeof(ParticleSystem)),//移动到BaseType目录里了
		_GT(typeof(AsyncOperation)).SetBaseType(typeof(System.Object)),
		_GT(typeof(LightType)),
		_GT(typeof(SleepTimeout)),
		_GT(typeof(Animator)),
		_GT(typeof(Input)),
		_GT(typeof(KeyCode)),
		_GT(typeof(SkinnedMeshRenderer)),
		_GT(typeof(Space)),

		_GT(typeof(MeshRenderer)),
		_GT(typeof(BoxCollider)),
		_GT(typeof(MeshCollider)),
		_GT(typeof(SphereCollider)),
		_GT(typeof(CharacterController)),
		_GT(typeof(CapsuleCollider)),

		_GT(typeof(Animation)),
		_GT(typeof(AnimationClip)).SetBaseType(typeof(UnityEngine.Object)),
		_GT(typeof(AnimationState)),
		_GT(typeof(AnimationBlendMode)),
		_GT(typeof(QueueMode)),
		_GT(typeof(PlayMode)),
		_GT(typeof(WrapMode)),

		_GT(typeof(QualitySettings)),
		_GT(typeof(RenderSettings)),
		_GT(typeof(SkinWeights)),
		_GT(typeof(RenderTexture)),
		_GT(typeof(Resources)),
		_GT(typeof(LuaProfiler)),

		//for LuaFramework
		_GT(typeof(Util)),
		_GT(typeof(AppConst)),
		_GT(typeof(LuaHelper)),
		_GT(typeof(ByteBuffer)),
		_GT(typeof(LuaBehaviour)),

		_GT(typeof(GameManager)),
		_GT(typeof(LuaManager)),
		_GT(typeof(PanelManager)),
		_GT(typeof(SoundManager)),
		_GT(typeof(TimerManager)),
		_GT(typeof(ThreadManager)),
		_GT(typeof(NetworkManager)),
		_GT(typeof(ResourceManager)),


		#region UGUI
		//_GT(typeof()),
		_GT(typeof(RectTransform)),
		_GT(typeof(Canvas)),
		_GT(typeof(CanvasGroup)),
		_GT(typeof(Button)).AddExtendType(typeof(ButtonExtension)),
		_GT(typeof(Toggle)),
		_GT(typeof(ToggleGroup)),
		_GT(typeof(Text)).AddExtendType(typeof(TextExtension)),
		_GT(typeof(Image)).AddExtendType(typeof(ShortcutExtensions)),
		_GT(typeof(Image.Type)),
		_GT(typeof(RawImage)),

		#endregion


		#region Game

		_GT(typeof(SimpleCamera)),
		_GT(typeof(MovableObject)),
		_GT(typeof(EditorResourceMgr)),
		_GT(typeof(EasyTouch)).SetNameSpace(null),
		_GT(typeof(UINameTable)).SetNameSpace(null),

		#endregion
	};

	public static List<Type> dynamicList = new List<Type>()
	{
		typeof(MeshRenderer),
		typeof(BoxCollider),
		typeof(MeshCollider),
		typeof(SphereCollider),
		typeof(CharacterController),
		typeof(CapsuleCollider),
		typeof(Animation),
		typeof(AnimationClip),
		typeof(AnimationState),
        typeof(SkinWeights),
        typeof(RenderTexture),
		typeof(Rigidbody),
	};

	//重载函数，相同参数个数，相同位置out参数匹配出问题时, 需要强制匹配解决
	//使用方法参见例子14
	public static List<Type> outList = new List<Type>()
	{
	};

	//ngui优化，下面的类没有派生类，可以作为sealed class
	public static List<Type> sealedList = new List<Type>()
	{
	};

	public static BindType _GT(Type t)
	{
		return new BindType(t);
	}

	public static DelegateType _DT(Type t)
	{
		return new DelegateType(t);
	}


	[MenuItem("Lua/Attach Profiler", false, 151)]
	static void AttachProfiler()
	{
		if (!Application.isPlaying)
		{
			EditorUtility.DisplayDialog("警告", "请在运行时执行此功能", "确定");
			return;
		}

		LuaClient.Instance.AttachProfiler();
	}

	[MenuItem("Lua/Detach Profiler", false, 152)]
	static void DetachProfiler()
	{
		if (!Application.isPlaying)
		{
			return;
		}

		LuaClient.Instance.DetachProfiler();
	}
}