using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

[RequireComponent(typeof(MeshCollider))]
[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(MeshFilter))]
public class CreateTerrain : MonoBehaviour
{
    // components
    private MeshFilter meshFilter;
    private MeshRenderer meshRenderer;
    private MeshCollider meshCollider;

    // terrain mesh
    private Mesh mesh;

    // lists for mesh verts, indices, and uvs
    List<Vector3> verts = new List<Vector3>();
    List<int> indices = new List<int>();
    List<Vector2> uvs = new List<Vector2>();

    // number of verts in the grid
    public Vector2Int gridSize = new Vector2Int(64, 64);
    // scale of the grid in unity units
    public Vector3 gridScale = new Vector3(64, 64, 64);
    // scale to sample perlin noise at
    public Vector2 perlinScale = new Vector2(0.1f, 0.1f);

    private float[,] m_heights;

    void Start()
    {
        meshFilter = GetComponent<MeshFilter>();
        meshRenderer = GetComponent<MeshRenderer>();
        meshCollider = GetComponent<MeshCollider>();

        createMesh();

        meshFilter.sharedMesh = mesh;
        meshCollider.sharedMesh = mesh;
    }

    // creates the mesh (only done once)
    void createMesh()
    {
        // reset mesh
        mesh = new Mesh();
        mesh.Clear();

        verts.Clear();
        indices.Clear();
        uvs.Clear();

        // gridSize can't go above 256x256
        gridSize.x = Mathf.Min(gridSize.x, 255);
        gridSize.y = Mathf.Min(gridSize.y, 255);

        // precalculate center of grid
        Vector2 gridCenter = new Vector2(gridScale.x * 0.5f, gridScale.z * 0.5f);

        // create mesh data
        for (int y = 0, i = 0; y < gridSize.y; y++)
        {
            for (int x = 0; x < gridSize.x; x++, i++)
            {
                // create vert
                float xPosition = (float)x / (float)gridSize.x * gridScale.x - gridCenter.x;
                float zPosition = (float)y / (float)gridSize.y * gridScale.y - gridCenter.y;

                verts.Add(new Vector3(xPosition, 0, zPosition));

                // create uv
                uvs.Add(new Vector2((float)x / (float)gridSize.x, (float)y / (float)gridSize.y));

                // add index (don't run off the end)
                if (x < gridSize.x - 1 && y < gridSize.y - 1)
                {
                    int i2 = i + 1;
                    int i3 = i + gridSize.x;
                    int i4 = i2 + gridSize.x;

                    indices.Add(i4);
                    indices.Add(i2);
                    indices.Add(i);

                    indices.Add(i);
                    indices.Add(i3);
                    indices.Add(i4);
                }
            }
        }

        // apply mesh data
        mesh.SetVertices(verts);
        mesh.SetIndices(indices.ToArray(), MeshTopology.Triangles, 0);
        mesh.SetUVs(0, uvs);

        // recalculate normals, etc.
        mesh.RecalculateBounds();
        mesh.RecalculateNormals();
        mesh.RecalculateTangents();
    }

    // set heights using perlin noise
    public void generatePerlin()
    {
        // precalculate center of grid
        Vector2 gridCenter = new Vector2(gridScale.x * 0.5f, gridScale.z * 0.5f);

        // update vertices
        for (int y = 0, i = 0; y < gridSize.y; y++)
        {
            for (int x = 0; x < gridSize.x; x++, i++)
            {
                // sample perlin noise
                float yPosition = Mathf.PerlinNoise(x * perlinScale.x, y * perlinScale.y);
                yPosition *= gridScale.y;

                float xPosition = (float)x / (float)gridSize.x * gridScale.x - gridCenter.x;
                float zPosition = (float)y / (float)gridSize.y * gridScale.z - gridCenter.y;

                verts[i] = new Vector3(xPosition, yPosition, zPosition);
            }
        }

        // apply verts and recalculate
        mesh.SetVertices(verts);

        mesh.RecalculateBounds();
        mesh.RecalculateNormals();
        mesh.RecalculateTangents();
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(CreateTerrain))]
public class CreateTerrainEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        CreateTerrain myScript = (CreateTerrain)target;

        if(GUILayout.Button("generate perlin"))
        {
            myScript.generatePerlin();
        }
    }
}
#endif