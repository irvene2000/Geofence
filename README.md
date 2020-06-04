# Geofence

This project demonstrates the use of Core Location and MapKit to determine if a user is currently within a geofence.

## Getting Started

After cloning the project. You should be able to run on any device.

### Prerequisites

```
Cocoapods
iOS Device (iOS 11.0 and after)
```

### Limitations

The project includes a feature to determine if a user is within the geofence by also looking to see if they are connected to a Wifi SSID.
However as of iOS 12, Apple requires a separate "Wifi Access Information" entitlement to be included in the project. Without a paid developer account, it's not possible to provision said entitlement. (details can be found in the footnote of https://developer.apple.com/documentation/systemconfiguration/1614126-cncopycurrentnetworkinfo)

The API to retrieve the current SSID also returns nil in the simulator and as such the recommended testing method is to use a physical device that is running iOS 11 to test that functionality.