//
//  YQCamera.h
//  MacOS-Demo
//
//  Created by RMKJ on 2019/5/27.
//  Copyright © 2019 RMKJ. All rights reserved.
//

#ifndef Camera_h
#define Camera_h

enum Camera_Movement {
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT
};

// Default camera values
const float YAW         = -90.0f;
const float PITCH       =  0.0f;
const float SPEED       =  30.0f;
const float SENSITIVITY =  0.1f;
const float ZOOM        =  45.0f;

class Camera {
    
    float deltaTime = 0.016; //刷新时间
    
public:
    // Camera Attributes
    glm::vec3 Position;
    glm::vec3 Front; //前面
    glm::vec3 Up; //上面
    glm::vec3 Right; //右边
    glm::vec3 WorldUp;
    // Euler Angles
    float Yaw;
    float Pitch;
    float ModelRotationAngle;
    // Camera options
    float MovementSpeed;
    float MouseSensitivity;
    float Zoom;
    
    Camera(glm::vec3 position = glm::vec3(0.0f, 0.0f, 0.0f), glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f), float yaw = YAW, float pitch = PITCH) : Front(glm::vec3(0.0f, 0.0f, -1.0f)), MovementSpeed(SPEED), MouseSensitivity(SENSITIVITY), Zoom(ZOOM) {
        Position = position;
        WorldUp = up;
        Yaw = yaw;
        Pitch = pitch;
        updateCameraVectors();
    }
    
    /**
     获取摄像机当前的位置
     */
    glm::vec3 GetPosition() {
        return Position;
    }
    
    glm::mat4 GetViewMatrix() {
        return glm::lookAt(Position, Position + Front, Up);
    }
    
    glm::mat4 GetModelMatrix(glm::mat4 originModel) {
        return glm::rotate(originModel, ModelRotationAngle, glm::vec3(0.0, 1.0, 0.0));
    }
    
    void onKeyBoardDown(char code) {
        float velocity = MovementSpeed * deltaTime;
        switch (code) {
            case 'A':
                Position -= Right * velocity;
                break;
            case 'D':
                Position += Right * velocity;
                break;
            case 'W':
                Position += Front * velocity;
                break;
            case 'S':
                Position -= Front * velocity;
                break;
            case 'N':
                Position += Up * velocity;
                break;
            case 'M':
                Position -= Up * velocity;
                break;
            default:
                break;
        }
    }
    
    // Processes input received from a mouse input system. Expects the offset value in both the x and y direction.
    void onMouseMove(float xoffset, float yoffset, GLboolean constrainPitch = true) {
        xoffset *= MouseSensitivity;
        yoffset *= MouseSensitivity;
        
        Yaw   += xoffset;
        Pitch += yoffset;
        
        // Make sure that when pitch is out of bounds, screen doesn't get flipped
        if (constrainPitch)
        {
            if (Pitch > 89.0f)
                Pitch = 89.0f;
            if (Pitch < -89.0f)
                Pitch = -89.0f;
        }
        
        // Update Front, Right and Up Vectors using the updated Euler angles
        updateCameraVectors();
    }
    
    void onRightMouseMove(float xoffset, GLboolean constrainPitch = true) {
        ModelRotationAngle += xoffset;
    }
    
    // Processes input received from a mouse scroll-wheel event. Only requires input on the vertical wheel-axis
    void ProcessMouseScroll(float yoffset) {
        if (Zoom >= 1.0f && Zoom <= 45.0f)
            Zoom -= yoffset;
        if (Zoom <= 1.0f)
            Zoom = 1.0f;
        if (Zoom >= 45.0f)
            Zoom = 45.0f;
    }
    
    void updateCameraVectors() {
        // Calculate the new Front vector
        glm::vec3 front;
        front.x = cos(glm::radians(Yaw)) * cos(glm::radians(Pitch));
        front.y = sin(glm::radians(Pitch));
        front.z = sin(glm::radians(Yaw)) * cos(glm::radians(Pitch));
        Front = glm::normalize(front);
        // Also re-calculate the Right and Up vector
        Right = glm::normalize(glm::cross(Front, WorldUp));  // Normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
        Up    = glm::normalize(glm::cross(Right, Front));
    }
};


#endif /* Camera */
