using UnityEngine;

public class MyController : MonoBehaviour
{
    public float speed = 5.0f; // speed of camera movement
    public float rotationSpeed = 200.0f; // speed of camera rotation

    public Transform cameraHolder; // the parent object of the camera

    private float pitch = 0.0f; // store the up and down rotation here

    private void Update()
    {
        float translation = speed * Time.deltaTime;
        float rotation = rotationSpeed * Time.deltaTime;

        // Move camera with WASD
        if (Input.GetKey(KeyCode.W))
            cameraHolder.transform.Translate(new Vector3(0, 0, 1) * translation);
        if (Input.GetKey(KeyCode.S))
            cameraHolder.transform.Translate(new Vector3(0, 0, -1) * translation);
        if (Input.GetKey(KeyCode.A))
            cameraHolder.transform.Translate(new Vector3(-1, 0, 0) * translation);
        if (Input.GetKey(KeyCode.D))
            cameraHolder.transform.Translate(new Vector3(1, 0, 0) * translation);

        // Move camera up and down with Q and E
        if (Input.GetKey(KeyCode.Q))
            cameraHolder.transform.Translate(new Vector3(0, -1, 0) * translation);
        if (Input.GetKey(KeyCode.E))
            cameraHolder.transform.Translate(new Vector3(0, 1, 0) * translation);

        // Look around with mouse movement
        float mouseX = Input.GetAxis("Mouse X");
        float mouseY = Input.GetAxis("Mouse Y");

        // Horizontal Mouse Movement - Rotate the holder
        cameraHolder.Rotate(Vector3.up, mouseX * rotation);

        // Vertical Mouse Movement - Rotate the camera
        pitch -= mouseY * rotation;
        pitch = Mathf.Clamp(pitch, -90f, 90f); // Limit vertical angle to -90/+90 degrees
        transform.localEulerAngles = new Vector3(pitch, 0, 0);
    }
}
