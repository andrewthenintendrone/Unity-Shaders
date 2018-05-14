using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(MeshCollider))]
public class CreateTerrain : MonoBehaviour
{
    private MeshFilter meshFilter;
    private MeshRenderer meshRenderer;
    private MeshCollider meshCollider;

    private Mesh myMesh;
    private List<Vector3> verts = new List<Vector3>();
    private List<int> tris = new List<int>();
    private List<Vector2> uvs = new List<Vector2>();

    // heightmap heights
    private List<float> heights = new List<float>();

    public Vector2 perlinScale;
    public Vector2 perlinScrollSpeed;
    private Vector2 perlinScroll = Vector2.zero;
    public Vector2 uvScrollSpeed;
    private Vector2 uvScroll = Vector2.zero;
    public Vector2Int gridScale;
    public Vector3 terrainScale;

    [Tooltip("diamond square feature size")]
    public int featureSize;

    void Start()
    {
        meshFilter = gameObject.GetComponent<MeshFilter>();
        meshRenderer = gameObject.GetComponent<MeshRenderer>();
        meshCollider = gameObject.GetComponent<MeshCollider>();

        myMesh = new Mesh();

        generateDiamondSquare();
        createMesh();
    }

    // creates the mesh
    void createMesh()
    {
        //float minY = 0;
        //float maxY = 0;

        //foreach (float height in heights)
        //{
        //    minY = Mathf.Min(minY, height * terrainScale.y);
        //    maxY = Mathf.Max(maxY, height * terrainScale.y);
        //}

        //meshRenderer.material.SetFloat("_LowestY", minY);
        //meshRenderer.material.SetFloat("_HighestY", maxY);

        myMesh.Clear();
        myMesh.name = "perlin_terrain";

        verts.Clear();
        tris.Clear();
        uvs.Clear();

        // generate geometry
        for (int x = 0, i = 0; x < gridScale.x; x++)
        {
            for (int z = 0; z < gridScale.y; z++, i++)
            {
                float newX = x / (float)gridScale.x * terrainScale.x - terrainScale.x / 2.0f;
                float newY = heights[i] * terrainScale.y;
                float newZ = z / (float)gridScale.y * terrainScale.z - terrainScale.z / 2.0f;

                verts.Add(new Vector3(newX, newY, newZ));
                uvs.Add(new Vector2(x / (float)gridScale.x, z / (float)gridScale.y));

                if (x < gridScale.x - 1 && z < gridScale.y - 1)
                {
                    int i2 = i + 1;
                    int i3 = i + gridScale.x;
                    int i4 = i + gridScale.x + 1;

                    tris.Add(i);
                    tris.Add(i2);
                    tris.Add(i3);

                    tris.Add(i3);
                    tris.Add(i2);
                    tris.Add(i4);
                }
            }
        }

        // set mesh geometry
        myMesh.SetVertices(verts);
        myMesh.SetTriangles(tris, 0);
        myMesh.SetUVs(0, uvs);

        myMesh.RecalculateBounds();
        myMesh.RecalculateNormals();
        myMesh.RecalculateTangents();

        meshFilter.sharedMesh = myMesh;
        meshCollider.sharedMesh = myMesh;
    }

    // generate heights using perlin noise
    void generatePerlin()
    {
        heights.Clear();

        for (int x = 0; x < gridScale.x; x++)
        {
            for (int y = 0; y < gridScale.y; y++)
            {
                heights.Add(Mathf.PerlinNoise(x * perlinScale.x + perlinScroll.x, y * perlinScale.y + perlinScroll.y));
            }
        }

        createMesh();
    }

    // generates heights using diamond square
    void generateDiamondSquare()
    {
        heights.Clear();

        // create dummy heights
        for (int i = 0; i < gridScale.x * gridScale.y; i++)
        {
            heights.Add(0);
        }

        int sampleSize = featureSize;
        float scale = 1.0f;

        while (sampleSize > 1)
        {
            DiamondSquare(sampleSize, scale);

            sampleSize /= 2;
            scale /= 2.0f;
        }

        createMesh();
    }

    public void rebuild()
    {
        generateDiamondSquare();
    }

    // diamond square functions
    float sample(int x, int y)
    {
        return heights[(x & (gridScale.x - 1)) + (y & (gridScale.y - 1)) * gridScale.x];
    }

    void setSample(int x, int y, float value)
    {
        heights[(x & (gridScale.x - 1)) + (y & (gridScale.y - 1)) * gridScale.x] = value;
    }

    void DiamondSquare(int stepsize, float scale)
    {
        int halfstep = stepsize / 2;

        for (int y = halfstep; y < gridScale.y + halfstep; y += stepsize)
        {
            for (int x = halfstep; x < gridScale.x + halfstep; x += stepsize)
            {
                sampleSquare(x, y, stepsize, Random.Range(-1.0f, 1.0f) * scale);
            }
        }

        for (int y = 0; y < gridScale.y; y += stepsize)
        {
            for (int x = 0; x < gridScale.x; x += stepsize)
            {
                sampleDiamond(x + halfstep, y, stepsize, Random.Range(-1.0f, 1.0f) * scale);
                sampleDiamond(x, y + halfstep, stepsize, Random.Range(-1.0f, 1.0f) * scale);
            }
        }
    }

    void sampleSquare(int x, int y, int size, float value)
    {
        int hs = size / 2;

        // a     b 
        //
        //    x
        //
        // c     d

        float a = sample(x - hs, y - hs);
        float b = sample(x + hs, y - hs);
        float c = sample(x - hs, y + hs);
        float d = sample(x + hs, y + hs);

        setSample(x, y, ((a + b + c + d) / 4.0f) + value);
    }

    void sampleDiamond(int x, int y, int size, float value)
    {
        int hs = size / 2;

        //   c
        //
        //a  x  b
        //
        //   d

        float a = sample(x - hs, y);
        float b = sample(x + hs, y);
        float c = sample(x, y - hs);
        float d = sample(x, y + hs);

        setSample(x, y, ((a + b + c + d) / 4.0f) + value);
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(CreateTerrain))]
public class CreateTerrainEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        CreateTerrain instance = (CreateTerrain)target;

        if(GUILayout.Button("rebuild"))
        {
            instance.rebuild();
        }
    }
}
#endif
