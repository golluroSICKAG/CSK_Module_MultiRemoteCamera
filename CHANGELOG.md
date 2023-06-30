# Changelog
All notable changes to this project will be documented in this file.

## Release 5.0.0

### Improvements
- Renamed abbreviations (Ui-UI, Fov-FOV, GigEvision-GigEVision, DigTrigger-DigitalTrigger, Fps-FPS, Ip-IP, Sw-SW, Hw-HW)
- Using recursive helper functions to convert Container <-> Lua table

## Release 4.6.0

### Improvements
- Update to EmmyLua annotations
- Usage of lua diagnostics
- Documentation updates

### Bugfix
- Do not set "GevStreamReceiveSocketSize" for SIM4000
- Some Enum references were missed

## Release 4.5.1

### Bugfix
- Minor docu / code edits

## Release 4.5.0

### Improvements
- error handling if wrong GigE camera is chosen 
- deactivated auto white balance for Basler a2A1929-51gcBAS

## Release 4.4.0

### Improvements
- Using internal moduleName variable to be usable in merged apps instead of _APPNAME, as this did not work with PersistentData module in merged apps.

## Release 4.3.0

### New features
- Making use of dynamic viewerIDs -> only one single viewer for all instances

### Improvements
- Naming of UI elements and adding some mouse over info texts
- Limiting width in GigE Vision UI (with very long GigE Vision parameter values UI became too wide)
- Reconfigure all camera instances by adding new camera instance in "switch mode", to update all cameras with ne camera amount
- Appname added to log messages
- Added ENUM
- Minor edits, docu, added log messages

### Bugfix
- Multiple Link to GigE Vision UI - removed
- UI events notified after pageLoad after 300ms instead of 100ms to not miss

## Release 4.2.0

### Improvements
- Loading only required APIs ('LuaLoadAllEngineAPI = false') -> less time for GC needed
- Use API load to check what feature is supported
- Update of helper funcs to support 4-dim tables for PersistentData
- Added module name prefix to processing file
- Check if I2D / GigEVision is supported on device
- Only try to load parameters from PersistentData module if Image.RemoteCamera API is supported on device
- Renamed event "OnNewParametersName" to "OnNewParameterName" (consistent to other modules)
- Optional info in UI regarding hidden features if UserManagement active
- Minor code edits / docu updates

### Bugfix
- Navigation in UI had wrong links

## Release 4.1.0

### Improvements
- Internal UI link to GigE Vision UI
- Event "OnNewImageSizeToShare" informs if image size changed, so that other modules can react on this
- Use timer to wait for camera boot up instead of blocking app via Script.sleep
- Show callout in UI if waiting for camera boot up
- Changed status type of user levels from string to bool
- Renamed page folder accordingly to module name
- Updated documentation

### Bugfix
- Local UserManagement AdminLevel status was missing

## Release 4.0.0

### New features
- Compatible with PersistentData ver 3.0.0 to save camera instances within Parameter binary file
- Possible to add new cameras during runtime (see "addInstance() / restartAllCameras() )
- CameraModels Midicam2 and Basler cam now chooseable on UI

### Improvements
- Renaming of "objects" to "instances" (e.g. multiRemoteCamerasObjects -> multiRemoteCameras_Instances)
- Events/Functions for instances are created now dynamically (sample entries available in docu)
- Switchmode/GigE Vision is not needed to configure via create function anymore
- Remove bandwith limitiation of the camera for other SIMs than SIM1012/SIM1004

## Release 3.2.0

### New features
- Added support for userlevels

### Bugfix
- Fixed setSwitchMode function

## Release 3.1.0

### New features
- Show all available GigE Vision Parameters in DynamicTable in UI
- Edit GigE Vision parameters via UI and show list of custom configs
- Updated GigE Vision parameter config procedure, (see updateConfig, addGigEVisionConfig, removeGigEVisionConfig, selectGigEVisionConfig)

### Improvements
- Possible to save sub tables via PersistentData module (needed for GigE Vision custom config parameters)
- Updated documentation

### Bugfix
- Updating of GigE Vision parameters did not work (removed functions "sendGigEvisionCommand", "setGigEVisionParameterType" )

## Release 3.0.0

### New features
- Update handling of persistent data according to CSK_PersistentData module ver. 2.0.0

## Release 2.6.0

### New features
- Saving all images (+ setting filename prefix) incl. format selection (BMP, JPG, PNG) + compression

### Improvements
- Documentation added (incl. API html-file)
- Interal image resizing (inside of the image processing script) is done now before it will be saved / forwarded to other apps
- Added "RAW8"-color mode
- All image processing parameters will be saved now (if PersistendData module is used)
- Reduced events (e.g. OnNewImageQueueCamera1-8 and OnNewFpsCamera1-8). Is solved by forwarding them via (MultiRemoteCamera_OnNewValueToForward1-8)
- Saving of (latest) image(s) now realized in camera threads (before all savings happend in same thread) and single save trigger now via  "Script.notifyEvent('MultiRemoteCamera_OnNewImageProcessingParameter', selectedCam, 'saveLastImage')"
- Update all image processing parameters by "loadParameters"
- Minor renaming / code movements

### Bugfix
- "setTempImageActive" always sent "true" to camera threads

## Release 2.5.0

### New features
- Second Page: Connected camera Overview

### Improvements
- Dynamical CameraList DropDown by cameraAmount
- ProcessingMode on UI
- updating imageProcessing parameters with "loadParameters" (not just on initial load)

### Bugfix
- viewerID changed to multiRemoteCameraViewer1-8
- internal logging works now again in parallel to Log module (switched config entries)

## Release 2.4.0

### New features
- New function to load/save parameters with SubContainer

## Release 2.3.0

### New features
- Viewer can be (de-)activated in UI

### Bugfix
- Camera is not started multiple times during connection (reason for Halcon error in the past)

## Release 2.2.0

### Improvements
- Only present image of currently selected camera in UI

## Release 2.1.0

### New features
- Calculate and show FPS on UI (Update every second)
- If config is available via PersistentData module wait 10 seconds for camera bootUp before connecting
- Module internal logging showing on module UI

### Improvements
-  Framerate can be set upt to 50
- OnNewImageQueue event returns type STRING (was INT)
- Default camera IP range starts at 192.168.0.100 (was 192.168.0.101)
- Reduced logging to prevent queue overload just because of logging

## Release 2.0.0

### New features
- GigEVision support
- Optionally load parameters at app restart
- Saving images on SD card or in public-folder
- Using PersistentData module if available to store parameters
- Color mode selectable on UI (not for GigEVision)
- Showing image queue size of current selected camera on UI

### Improvements
- Auto connecting of camera if parameters were saved
- Using new camera config if new parameters are used
- Using unique local event names

## Release 1.0.0
- Initial commit