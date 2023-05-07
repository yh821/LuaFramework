using System;
using HedgehogTeam.EasyTouch;
using UnityEditor.Experimental;
using UnityEngine;
using UnityEngine.EventSystems;

namespace Game.Scripts
{
	public class SceneDriver : MonoBehaviour
	{
		public enum MoveState
		{
			Idle,
			Move,
			Fly,
			Tap,
		}

		private SimpleCamera _camera;
		private GameObject _player;

		private int _idleHash;
		private int _moveHash;
		private int _flyHash;

		private float _flyHeight;

		private Animator _animator;
		private MovableObject _movable;
		private Vector3 _moveTo;
		private float _moveSpeed = 6;
		private float _rotaSpeed = 10;

		private MoveState _moveState;

		public MoveState moveState
		{
			get => _moveState;
			set
			{
				if (_moveState == value) return;
				_moveState = value;
				if (!_animator) return;
				var hash = _idleHash;
				if (value == MoveState.Fly)
					hash = _flyHash;
				else if (value == MoveState.Move || value == MoveState.Tap)
					hash = _moveHash;
				_animator.CrossFade(hash, 0.2f);
			}
		}

		private void Awake()
		{
			_idleHash = Animator.StringToHash("idle");
			_moveHash = Animator.StringToHash("run");

			InitActor();
		}

		void InitActor()
		{
			_player = Instantiate(EditorResourceMgr.LoadGameObject("actors/role_prefab", "Boy"), GameObject.Find("GameRoot/SceneObjLayer").transform, false);
			_player.gameObject.name = "Boy";
			_animator = _player.GetComponent<Animator>();
			_movable = _player.GetComponent<MovableObject>();

			_camera = Camera.main.GetComponent<SimpleCamera>();
			_camera.target = _player.transform;
			_camera.targetOffset = Vector3.up * 1.2f;

			EasyTouch.On_SimpleTap += OnSimpleTap;
		}

		private void Update()
		{
			if (!_movable) return;
			var moveDir = Vector2.zero;
			if (Input.GetKey(KeyCode.W))
				moveDir += Vector2.up;
			if (Input.GetKey(KeyCode.S))
				moveDir += Vector2.down;
			if (Input.GetKey(KeyCode.A))
				moveDir += Vector2.left;
			if (Input.GetKey(KeyCode.D))
				moveDir += Vector2.right;

			if (Input.GetKey(KeyCode.Space))
				FashMove();

			if (moveDir != Vector2.zero)
				moveDir = CalcMoveDir(moveDir.x, moveDir.y).normalized;
			if (moveState == MoveState.Fly)
				UpdateFly(moveDir);
			else
				UpdateMove(moveDir);
		}

		private void UpdateMove(Vector2 moveDir)
		{
			if (moveDir != Vector2.zero)
			{
				moveState = MoveState.Move;
				var target = new Vector3(moveDir.x, 0, moveDir.y);
				target = target * 2f + _movable.transform.position;
				_movable.RotateTo(target, _rotaSpeed);
				_movable.MoveTo(target, _moveSpeed);
			}
			else
			{
				if (moveState == MoveState.Move)
				{
					moveState = MoveState.Idle;
					_movable.StopMove();
				}
			}
		}

		void UpdateFly(Vector2 moveDir)
		{
			var target = new Vector3(moveDir.x, 0, moveDir.y);
			target = target * (_moveSpeed * Time.deltaTime) + _movable.transform.position;
			var minHeight = MovableObject.GetWalkableHeight(target.x, target.z, 0);
			if (Input.GetKey(KeyCode.Q))
				_flyHeight += Time.deltaTime * 15f;
			if (Input.GetKey(KeyCode.E))
				_flyHeight -= Time.deltaTime * 15f;
			if (_flyHeight < minHeight)
				_flyHeight = minHeight;
			target.y = _flyHeight;
			_movable.transform.position = target;
			if (moveDir != Vector2.zero)
			{
				var lookDir = new Vector3(moveDir.x, 0, moveDir.y);
				var targetRotation = Quaternion.LookRotation(lookDir);
				var rotation = _movable.transform.rotation;
				rotation = Quaternion.Slerp(rotation, targetRotation, Time.deltaTime * _rotaSpeed);
				_movable.transform.rotation = rotation;
			}
		}

		private Vector2 CalcMoveDir(float moveDirX, float moveDirY)
		{
			var rotation = new Quaternion();
			var screen_forward = new Vector3(0, 0, 1);
			var screen_input = new Vector3(moveDirX, 0, moveDirY);
			rotation.SetFromToRotation(screen_forward, screen_input);
			rotation.eulerAngles = new Vector3(rotation.eulerAngles.x, rotation.eulerAngles.y, 0);
			var camera_forward = Camera.main.transform.forward;
			camera_forward.y = 0;
			var move_dir = rotation * camera_forward;
			return new Vector2(move_dir.x, move_dir.z);
		}

		private void OnSimpleTap(Gesture gesture)
		{
			var ray = Camera.main.ScreenPointToRay(gesture.position);
			var hit = Physics.RaycastAll(ray, Mathf.Infinity, 1 << LayerMask.NameToLayer("Walkable"));
			if (hit.Length > 0)
			{
				var point = hit[0].point;
				_moveTo = point;
				moveState = MoveState.Tap;
				_movable.RotateTo(point, _rotaSpeed);
				_movable.MoveTo(point, _moveSpeed, typo =>
				{
					if (moveState == MoveState.Tap)
						moveState = MoveState.Idle;
				});
			}
		}

		private void FashMove()
		{
			if (_moveTo == Vector3.zero) return;
			_movable.transform.position = _moveTo;
			moveState = MoveState.Idle;
			_moveTo = Vector3.zero;
		}
	}
}