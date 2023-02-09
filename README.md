# Fully working video app for iOS: Video player, Smooth scrolling, Upload

## Demo
<img src="/gif/iOS_Vod_demo_github.gif"/>

## Introduction
Setup VOD viewing in 15 minutes in your iOS project instead of 7 days of work and setting network, smooth scrolling, upload parameters etc. This demo project is a quick tutorial how to view video from your own mobile app to an audience of 1 000 000+ views like Instagram, Youtube, etc.

## Feature
1) HLS playback,
2) Upload new video via TUSKit,
3) authorization on Gcore services,
4) Support for smooth scrolling.
 
## Quick start 
  1) Launching the application via xcode (it must be run on a real device, since the simulator does not support the camera),
  2) Authorization via email and password of the personal account in Gcore,
  3) On the viewing screen, you can start viewing VOD with smooth scrolling,
  4) On the upload screen, you can start record and push video on the Gcore.

## Setup of project
Clone this project and try it or create a new one.

1) Library <br />
    a) [TUSKit](https://github.com/tus/TUSKit) - To perform asynchronous video upload to the server, we recommend using  version 2.2.1   
This version makes it easy to use metadata to send files. You can easily add via SPM specifying git libraries with the version.
    b) [Texture](https://github.com/TextureGroup/Texture) - To perform asynchronous UI, and smooth scrolling via table node realization.
  
2) Permissions <br />
  To use the camera and microphone, you need to request the user's permission for this. To do this, add to the plist (Info) of the project:
  **Privacy - Camera Usage Description** and **Privacy - Microphone Usage Description**. <br />

    Also, to record sound in the background, you need to add a **background mode** - **"Audio, AirPlay and Picture in Picture"**

3) Gcore API
  To interact with the server, the **HTTPCommunicator** structure is used, through the API:
  ```swift
enum GcoreAPI: String {
    case authorization = "https://api.gcore.com/iam/auth/jwt/login"
    case videos = "https://api.gcore.com /streaming/videos"
    case refreshToken = "https://api.gcore.com/iam/auth/jwt/refresh"
}
  ```
  Which create the necessary request through the **HTTPCommunicator** struct.
  For more check Gcore API [documentation](https://apidocs.gcore.com/streaming).
  
## Requirements
  1) iOS min - 12.1,
  2) Real device (not simulator),
  3) The presence of an Internet connection on the device,
  4) The presence of a camera and microphone on the device.
  
## License
Copyright 2022 Gcore
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

