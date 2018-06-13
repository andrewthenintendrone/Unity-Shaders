using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlyCamera : MonoBehaviour
{
    float walkSpeed = 10.0f;
    float runSpeed = 50.0f;

    float pitch = 0;
    float yaw = 0;
    float sensitivity = 2.0f;

    void Update ()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        pitch -= Input.GetAxis("Mouse Y") * sensitivity;
        yaw += Input.GetAxis("Mouse X") * sensitivity;

        pitch = Mathf.Min(pitch, 89.0f);
        pitch = Mathf.Max(pitch, -89.0f);

        transform.eulerAngles = new Vector3(pitch, yaw, 0);

        float velocity = (running() ? runSpeed : walkSpeed) * Time.deltaTime;

        Vector3 movement = Vector3.zero;

        movement += transform.forward * Input.GetAxisRaw("Vertical");
        movement += transform.right * Input.GetAxisRaw("Horizontal");

        movement = movement * velocity;

        transform.Translate(movement, Space.World);
    }

    bool running()
    {
        return Input.GetKey(KeyCode.LeftShift);
    }
}
