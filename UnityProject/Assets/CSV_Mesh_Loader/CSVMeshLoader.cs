using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

using System.IO;

public class CSVMeshLoader : MonoBehaviour
{

    public string filename = "CSV_Mesh_Test.txt";
    public bool hasHeader = true;
    float [] x;
    float [] y;
    float [] z;
    float [] r;
    float [] g;
    float [] b;
    float [] a;
    GameObject [] Submeshes;
    public GameObject Submesh_PRE = null;
    public int vertexLimit = 2;

    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(createSubmeshesFromFile(filename));

    }

    private int ParseFloatArrayFromLine(string line, char delimiter, float [] values)
    {
        int startIndex = 0;
        int endIndex = line.IndexOf(delimiter);
        int fieldCount = 0;

        while (endIndex >= 0)
        {
            fieldCount++;
            startIndex = endIndex + 1;
            endIndex = line.IndexOf(delimiter, startIndex);
        }

        fieldCount++; // Account for the last field

        startIndex = 0;
        endIndex = line.IndexOf(delimiter);
        int arrayIndex = 0;

        while (endIndex >= 0 && arrayIndex < values.Length)
        {
            values[arrayIndex++] = float.Parse(line.Substring(startIndex, endIndex - startIndex));
            startIndex = endIndex + 1;
            endIndex = line.IndexOf(delimiter, startIndex);
        }

        // Process the last field
        if(arrayIndex < values.Length) values[arrayIndex] = float.Parse(line.Substring(startIndex));

        return fieldCount;
    }

    public IEnumerator createSubmeshesFromFile(string filename)
	{

        int yieldMax = 1000;
        int yieldCount = 0;
        StreamReader sr = IOExtras.getReader(filename);
        string line;

        x = new float[vertexLimit];
        y = new float[vertexLimit];
        z = new float[vertexLimit];
        r = new float[vertexLimit];
        g = new float[vertexLimit];
        b = new float[vertexLimit];
        a = new float[vertexLimit];
        float[] values = new float[7];
        int i=0;
        if(hasHeader) sr.ReadLine();
        while (!sr.EndOfStream)
        {
            line = sr.ReadLine();

            int fieldCount = ParseFloatArrayFromLine(line, ',', values);

            x[i] = values[0];
            y[i] = values[1];
            z[i] = values[2];
            if (fieldCount >= 6)
            {
                r[i] = values[3];
                g[i] = values[4];
                b[i] = values[5];
            }
            else
            {
                r[i] = 1.0f;
                g[i] = 1.0f;
                b[i] = 1.0f;
            }
            if (fieldCount >= 7)
            {
                a[i] = values[6];
            }
            else
            {
                a[i] = 1.0f;
            }

            i++;

            if (i % vertexLimit == 0)
            {
                createSubmesh(vertexLimit);
                i=0;
            }

            if (yieldCount++ > yieldMax)
            {
                yieldCount = 0;
                //Debug.Log("yielding");
                // Debug.Log(string.Format("nVertices {0:d}", i));
                yield return null;
            }
            
        }
       
        sr.Close();
        //sr = IOExtras.getReader(filename);

        if(i%vertexLimit!=0)
		{
            createSubmesh(i);
		}
        
    }

    public void createSubmesh(int n)
	{
       
        Debug.Log(n);
        Vector3[] points = new Vector3[n];
        Color[] colors = new Color[n];
        int[] indices = new int[n];
        for (int i = 0; i < n; i++)
        {
            points[i] = new Vector3(x[i], y[i], z[i]);
            colors[i] = new Color(r[i], g[i], b[i], a[i]);
            indices[i] = i;
        }

        Mesh mesh = new Mesh();
        mesh.indexFormat = IndexFormat.UInt32;
        mesh.vertices = points;
        mesh.colors = colors;
        mesh.SetIndices(indices, MeshTopology.Points, 0);
        mesh.RecalculateBounds();

        GameObject submesh = Instantiate(Submesh_PRE);
        submesh.transform.parent = transform;
        submesh.transform.localPosition = Vector3.zero;
        submesh.transform.localScale = Vector3.one;

        submesh.GetComponent<MeshFilter>().mesh = mesh;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
