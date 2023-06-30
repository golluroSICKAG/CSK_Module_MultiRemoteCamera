--MIT License
--
--Copyright (c) 2023 SICK AG
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
-----------------------------------------------------------
-- If app property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
_G.availableAPIs = require('Sensors/MultiRemoteCamera/helper/checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device
-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger module is not used
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setLevel("ALL")

--- Callback sink function to notify incoming log messages inside of the module (e.g. for UI) even without CSK Logger module
---@param message string Content of the transmitted logging message
---@param path string Source path of the component that emitted the logging message
---@param level string Log level (severity) of the message
---@param timestamp number Timestamp as milliseconds since epoch (unix timestamp)
---@param appName string Name of the App that emitted the logging message (optional)
---@param appPosition string File and line position in the App source code (optional)
---@param sourceApi string Name of the API that the logging message was sent from (optional)
local function loggerCallback(message, path, level, timestamp, appName, appPosition, sourceApi)
  Script.notifyEvent('MultiRemoteCamera_OnNewLoggingMessage', message)
end
Log.Handler.addCallbackSink(_G.logHandle, loggerCallback)
_G.logHandle:applyConfig()
-----------------------------------------------------------

-- Loading script regarding MultiRemoteCamera_Model
-- Check this script regarding camera parameters and functions
local multiRemoteCamera_Model = require('Sensors/MultiRemoteCamera/MultiRemoteCamera_Model')

local multiRemoteCameras_Instances = {} -- Handle all instances

-- Add other camera instances during runtime e.g. via
--CSK_MultiRemoteCamera.addInstance()

-- Load script to communicate with the MultiRemoteCamera_Model UI
-- Check / edit this script to see/edit functions which communicate with the UI
local multiRemoteCameraController = require('Sensors/MultiRemoteCamera/MultiRemoteCamera_Controller')

-- Check if specific APIs are available on device
if availableAPIs.imageProvider then
  _G.logger:info("I2D Support = " .. tostring(_G.availableAPIs.I2D) .. ", GigEVision support = " .. tostring(_G.availableAPIs.GigEVision))
  table.insert(multiRemoteCameras_Instances, multiRemoteCamera_Model.create(1)) -- create(cameraNo:int)
  multiRemoteCameraController.setMultiRemoteCamera_Instances_Handle(multiRemoteCameras_Instances) -- share handle of instances
else
  _G.logger:warning("CSK_MultiRemoteCamera : Features of this module are not supported on this device. Missing APIs.")
end

--**************************************************************************
--**********************End Global Scope ***********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on startup event of the app
local function main()

  multiRemoteCameraController.setMultiRemoteCamera_Model_Handle(multiRemoteCamera_Model) -- share handle of model
  ----------------------------------------------------------------------------------------
  -- INFO: Please check if module will eventually load inital configuration triggered via
  --       event CSK_PersistentData.OnInitialDataLoaded
  --       (see internal variable _G.multiRemoteCamerasObjects.parameterLoadOnReboot)
  --
  -- Could be used e.g. like this:
  ----------------------------------------------------------------------------------------

  --[[
  -- If internal cFlow for digital trigger should be used, but normally the "CSK_DigitalIOManager" should be used...
  local digitalTriggerFlow = Flow.create()
  digitalTriggerFlow:load('resources/CSK_Module_MultiRemoteCamera/CameraTrigger.cflow')

  multiRemoteCameraInterface.setFlowHandle(digitalTriggerFlow)
  digitalTriggerFlow:start()

  --multiRemoteCameras_Instances[1].parameters.triggerDelayBlockName ='delay-Camera1' --> define the related triggerDelay of the Flow
  --multiRemoteCameras_Instances[1].parameters.cameraIP ='192.168.1.100'
  --multiRemoteCameras_Instances[2]:connectCamera() --> Can be connected+started via UI
  --multiRemoteCameras_Instances[2]:startCamera()

  --multiRemoteCameras_Instances[2].parameters.triggerDelayBlockName ='delay-Camera2'  --> define the related triggerDelay of the Flow
  --multiRemoteCameras_Instances[2].parameters.cameraIP ='192.168.1.110'
  --multiRemoteCameras_Instances[2]:connectCamera() --> Can be connected+started via UI
  --multiRemoteCameras_Instances[2]:startCamera()

  ]]
  ----------------------------------------------------------------------------------------
  CSK_MultiRemoteCamera.pageCalled() -- Update UI
end
Script.register("Engine.OnStarted", main)

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************