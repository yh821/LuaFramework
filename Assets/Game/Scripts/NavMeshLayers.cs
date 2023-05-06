using UnityEngine.AI;

public static class NavMeshLayers
{
	private static int? walkable;
	private static int? water;
	private static int? road;

	public static int Walkable
	{
		get
		{
			if (!walkable.HasValue)
				walkable = NavMesh.GetAreaFromName("Walkable");
			return walkable.Value;
		}
	}

	public static int Water
	{
		get
		{
			if (!water.HasValue)
				water = NavMesh.GetAreaFromName("Water");
			return water.Value;
		}
	}

	public static int Road
	{
		get
		{
			if (!road.HasValue)
				road = NavMesh.GetAreaFromName("Road");
			return road.Value;
		}
	}
}