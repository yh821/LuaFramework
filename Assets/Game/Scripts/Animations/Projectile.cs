using System;
using UnityEngine;

public abstract class Projectile : MonoBehaviour
{
	public abstract void Play(Vector3 sourceScale, Transform target, int layer, Action hitted, Action complete);
}