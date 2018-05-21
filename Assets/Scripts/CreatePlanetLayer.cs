using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreatePlanetLayer : MonoBehaviour
{
    public GameObject tilePrefab;

    public int rows, columns;
    public float radius;
    public Vector3 cubeScale = new Vector3(1, 1, 1);

    private int latMin = -90;
    private int latMax = 90;
    private int longMin = 0;
    private int longMax = 360;

    List<Vector3> positions;

	void Start ()
    {
        initialisePositions();

        for(int i = 0; i < positions.Count; i++)
        {
            GameObject newCube = Instantiate(tilePrefab, transform);
            newCube.name = "Cube_" + (i + 1);

            newCube.transform.position = positions[i];
            newCube.transform.localScale = cubeScale;
            newCube.transform.LookAt(transform);
        }
    }

    void initialisePositions()
    {
        float inverseRadius = 1.0f / radius;

        // invert these first as the multiply is slightly quicker
        float invColumns = 1.0f / columns;
        float invRows = 1.0f / rows;

        //Lets put everything in radians first
        float latitiudinalRange = (latMax - latMin) * Mathf.Deg2Rad;
        float longitudinalRange = (longMax - longMin) * Mathf.Deg2Rad;

        // for each row of the mesh
        positions = new List<Vector3>();

        for (int row = 0; row <= rows; row++)
        {
            // y ordinates this may be a little confusing but here we are navigating around the xAxis in GL
            float ratioAroundXAxis = (float)row * invRows;
            float radiansAboutXAxis = ratioAroundXAxis * latitiudinalRange + (latMin * Mathf.Deg2Rad);
            float y = radius * Mathf.Sin(radiansAboutXAxis);
            float z = radius * Mathf.Cos(radiansAboutXAxis);

            for (int col = 0; col <= columns; col++)
            {
                float ratioAroundYAxis = (float)col * invColumns;
                float theta = ratioAroundYAxis * longitudinalRange + (longMin * Mathf.Deg2Rad);
                Vector3 v4Point = new Vector3(-z * Mathf.Sin(theta), y, -z * Mathf.Cos(theta));

                bool alreadyExists = false;
                foreach(Vector3 position in positions)
                {
                    if(position == v4Point)
                    {
                        alreadyExists = true;
                        break;
                    }
                }

                if(!alreadyExists)
                {
                    positions.Add(v4Point);
                }
            }
        }
    }
}
    
