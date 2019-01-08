# BlueSocketNetworking
A project for FRC Team 4028 to use an iPhone for computer vision applications on the robot. The robot and the iPhone communicate through a TCP Socket. The iPhone and robot are connected by an Apple Lightning to USB 3 Camera Adapter, a USB to Ethernet adapter, and an Ethernet cable.

IBM Blue Socket provides the framework for the iPhone to interact with raw TCP Sockets instead of URLSession. It can be found here: https://www.github.com/IBM-Swift/BlueSocket.

Apple's built-in Vision framework (iOS 11.0+) provides rectangle detection and tracking algorithms to be used with a green light on the field. Using the field of view and the size of the frame, the goal is to calculate the difference of the target to the center of the frame in degrees.

There are two filters in this project. The first is a color filter, using a CIColorKernel. A minimum and maximum RGB value is specified, and CoreImage filters the image as black and white. The second filter will be an aspect ratio.

### Project Checklist

- [x] TCP Socket Initialized
- [x] TCP Socket communnicates random JSON data to robot 
- [x] Camera is set up
- [x] Color filter
- [x] Rectangle detection
- [x] Rectangle tracking
- [x] Calculating angle from data
- [x] [Custom ML YOLO Model detection](https://github.com/technology08/2019-Data-Capture)
- [ ] Custom ML YOLO Model tracking
- [x] Sending correct data over in a JSON format to robot
