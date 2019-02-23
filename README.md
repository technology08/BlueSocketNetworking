# BlueSocketNetworking
A project for FRC Team 4028 to use an iPhone for computer vision applications on the robot. The robot and the iPhone communicate through a TCP Socket. The iPhone and robot are connected by an Apple Lightning to USB 3 Camera Adapter, a USB to Ethernet adapter, and an Ethernet cable.

IBM Blue Socket provides the framework for the iPhone to interact with raw TCP Sockets instead of `URLSession`. It can be found here: https://www.github.com/IBM-Swift/BlueSocket.

Apple's built-in Vision framework (iOS 11.0+) provides rectangle detection and tracking algorithms to be used with a green light on the field. Using the field of view and the size of the frame, the goal is to calculate the difference of the target to the center of the frame in degrees.

There are three filters in this project. The first is a  color filter, using a `CIColorKernel`. A minimum and maximum RGB value is specified, and CoreImage filters the image as black and white. The second filter will be an aspect ratio. The third filter will look at the negative space between the two detected rectangles to ensure they are not tiny points.

### Project Checklist

- [x] TCP Socket Initialized
- [x] TCP Socket communnicates random JSON data to robot 
- [x] Camera is set up
- [x] Color filter
- [ ] Negative space filter
- [x] Rectangle detection
- [x] Rectangle tracking
- [x] Calculating angle from data
- [x] Calculating height from data
- [x] Sending correct data over in a JSON format to robot

## How it Works

There are two sides to this project: the TCP Socket Server (`Socket.swift`) and the Vision processing. 

## TCP Server

`Socket.swift` contains the TCP server. This **should not** change year-to-year, but rather use public methods to interact with it. To run the server, run the `runServer(port:)` function in `ViewController.swift`. When the code string `"VISION"` is sent by the socket client, the server will return the fetch latest vision data, thread-locking the value, with the private method `getVisionData()`, and write it to the client. To update the vision data to be sent, use `setVisionData(data:)` to securely (via thread-locking) update the vision data. To shutdown the server at any time, send the string `"SHUTDOWN"`. Please be advised that you will have to currently **restart the app** to restart the server, so this should not be used unless an emergency.

## Data Structure

The file `VisionData.swift` contains the data structure for both parsing the observations from Vision and sending the observations over BlueSocket. It can be sent either as a JSON, conforming to the `Codable` protocol, or a pipe-separated string. We elected to use the latter option, creating and utilizing the `getPipeString()` method. `|` separates the different values, and `^` is the key-value separator, as `:` was used in the timestamp.

## Vision Processing

Here is the biggest portion of the project, that lives in `Rectangle.swift` (`CoreML.swift` is a deprecated research avenue using a custom-trained YOLO Turi Create neural network, not as performant). It uses the [`VNRectangleDetectionRequest`](https://developer.apple.com/documentation/vision/vndetectrectanglesrequest) detection algorithm found in `detectRect(ciImage:)`. It detects up to 6 rectangles, and creates a CGImage to form negative space as black, not nil, pixels. The detection handler can be found in `detectRectHandler(request:, error:)`, where it is then passed on to a `detectionHandler(results:)`.

The vision targets for the 2019 FRC game consisted of two rectangles slanted in towards each other, where it removes objects below a height threshold and with a certain amount of negative space (this should be moved to the group results). It then sorts the observations left to right, and sorts them into `leftResults` and `rightResults`. It selects the first left rectangle (for now) and the very next right rectangle, runs an equation to ensure that lines drawn from the corners would intersect below the topLeft point (hence the fitting func name of `isIntersectionAbove`). 

Once these two rectangles are found, they are tracked *independently* with two separate trackers. However, the `groupResults(target1:, target2:)` calculates the degrees from the center and distance based on area % regression.
