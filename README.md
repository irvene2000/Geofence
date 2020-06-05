# Geofence

This project demonstrates the use of Core Location and MapKit to determine if a user is currently within a geofence.

## Getting Started

After cloning the project. Open the Geofence.xcworkspace file and you should be able to build and run. Tested on Xcode 11. Use Command+R to build to the selected simulator or device while Command+U will execute the test suite which currently only contains unit tests for ViewModel.swift.

In the unlikely event that the app fails to run. Go to terminal and navigate to the root project directory and run 
```
pod install
```
before trying again.

The way you establish a geofence is by clicking on a location on the map with a single tap. This will draw a circle geofence around the point that you have clicked on. The radius of the circle can be adjusted by keying it in the second textfield from the top. The app will also detect your currently connected SSID if you are running on a physical iOS 11 device. Assuming the keyed in SSID matches the connected SSID, the label at the bottom will also indicate that user is within the geofence. Disclaimer: Using the SSID is not the most reliable because a different network could have the same name. However, in an effort to ease testing, I've opted to use that instead of using the wifi BSSID.

### Prerequisites

```
Cocoapods
iOS Device (iOS 11.0 and after)
```

### Limitations

The project includes a feature to determine if a user is within the geofence by also looking to see if they are connected to a Wifi SSID.
However as of iOS 12, Apple requires a separate "Wifi Access Information" entitlement to be included in the project. Without a paid developer account, it's not possible to provision said entitlement. (details can be found in the footnote of https://developer.apple.com/documentation/systemconfiguration/1614126-cncopycurrentnetworkinfo)

The API to retrieve the current SSID also returns nil in the simulator and as such the recommended testing method is to use a physical device that is running iOS 11 to test that functionality.
