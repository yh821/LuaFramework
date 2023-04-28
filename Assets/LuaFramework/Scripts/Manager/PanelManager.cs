using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using LuaInterface;

namespace LuaFramework {
    public class PanelManager : Manager {
        private Transform parent;

        Transform Parent {
            get {
                if (parent == null) {
                    GameObject go = GameObject.FindWithTag("GuiCamera");
                    if (go != null) parent = go.transform;
                }
                return parent;
            }
        }

        /// <summary>
        /// 创建面板，请求资源管理器
        /// </summary>
        /// <param name="type"></param>
        public void CreatePanel(string name, LuaFunction func = null) {
#if ASYNC_MODE
            string assetName = name + "Panel";
            string abName = name.ToLower() + AppConst.ExtName;
            if (Parent.Find(name) != null) return;
            ResManager.LoadPrefab(abName, assetName, delegate(UnityEngine.Object[] objs) {
                if (objs.Length == 0) return;
                var prefab = objs[0] as GameObject;
                if (prefab == null) return;

                var go = Instantiate(prefab, Parent, true);
                go.name = assetName;
                go.layer = LayerMask.NameToLayer("Default");
                go.transform.localScale = Vector3.one;
                go.transform.localPosition = Vector3.zero;
                go.AddComponent<LuaBehaviour>();

                if (func != null) func.Call(go);
                Debug.LogWarning("CreatePanel::>> " + name + " " + prefab);
            });
#else
            var assetName = name + "Panel";
            if (Parent.Find(name) != null) return;
            var prefab = ResManager.LoadAsset<GameObject>(name, assetName);
            if (prefab == null) return;

            var go = Instantiate(prefab, Parent, true);
            go.name = assetName;
            go.layer = LayerMask.NameToLayer("Default");
            go.transform.localScale = Vector3.one;
            go.transform.localPosition = Vector3.zero;
            go.AddComponent<LuaBehaviour>();

            if (func != null) func.Call(go);
            Debug.LogWarning("CreatePanel: " + name + " " + prefab);
#endif
        }

        /// <summary>
        /// 关闭面板
        /// </summary>
        /// <param name="name"></param>
        public void ClosePanel(string name) {
            var panelName = name + "Panel";
            var panelObj = Parent.Find(panelName);
            if (panelObj == null) return;
            Destroy(panelObj.gameObject);
        }
    }
}