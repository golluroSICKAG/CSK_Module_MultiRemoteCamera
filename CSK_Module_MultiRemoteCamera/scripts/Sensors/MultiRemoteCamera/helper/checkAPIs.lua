---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Load all relevant APIs for this module
--**************************************************************************

local availableAPIs = {}

-- Function to load all default APIs
local function loadAPIs()

  CSK_MultiRemoteCamera = require 'API.CSK_MultiRemoteCamera'

  Log = require 'API.Log'
  Log.Handler = require 'API.Log.Handler'
  Log.SharedLogger = require 'API.Log.SharedLogger'

  Container = require 'API.Container'
  DateTime = require 'API.DateTime'
  Engine = require 'API.Engine'
  File = require 'API.File'
  Object = require 'API.Object'
  Timer = require 'API.Timer'

  -- Check if related CSK modules are available to be used
  local appList = Engine.listApps()
  for i = 1, #appList do
    if appList[i] == 'CSK_Module_PersistentData' then
      CSK_PersistentData = require 'API.CSK_PersistentData'
    elseif appList[i] == 'CSK_Module_UserManagement' then
      CSK_UserManagement = require 'API.CSK_UserManagement'
    elseif appList[i] == 'CSK_Module_FlowConfig' then
      CSK_FlowConfig = require 'API.CSK_FlowConfig'
    end
  end
end

-- Function to load specific APIs
local function loadSpecificAPIs()
  -- If you want to check for specific APIs/functions supported on the device the module is running, place relevant APIs here
  Image = require 'API.Image'
  Image.Provider = {}
  Image.Provider.RemoteCamera = require 'API.Image.Provider.RemoteCamera'
  Ethernet = require 'API.Ethernet'
  Ethernet.Interface = require 'API.Ethernet.Interface'
  Flow = require 'API.Flow'
  Image = require 'API.Image'
  View = require 'API.View'
end

-- Function to load specific I2D APIs
local function loadI2DSpecificAPIs()
  Image.Provider.RemoteCamera.I2DConfig = require 'API.Image.Provider.RemoteCamera.I2DConfig'
end

-- Function to load specific GigE Vision APIs
local function loadGigEVisionSpecificAPIs()
  Image.Provider.RemoteCamera.GigEVisionConfig = require 'API.Image.Provider.RemoteCamera.GigEVisionConfig'
end

-- Function to load specific SEC100 APIs
local function loadSEC100SpecificAPIs()
  HTTPClient = require 'API.HTTPClient'
  HTTPClient.Request = require 'API.HTTPClient.Request'
  HTTPClient.Response = require 'API.HTTPClient.Response'

  Hash = {}
  Hash.SHA256 = require 'API.Hash.SHA256'

  Image.Format = {}
  Image.Format.JPEG = require 'API.Image.Format.JPEG'

  -- Check if related CSK modules are available to be used
  local appList = Engine.listApps()
  for i = 1, #appList do
    if appList[i] == 'CSK_Module_MultiHTTPClient' then
      CSK_MultiHTTPClient = require 'API.CSK_MultiHTTPClient'
    end
  end
end

-- Function to load specific SEC100 Stream APIs
local function loadSEC100StreamSpecificAPIs()
  WebsocketClient = require 'API.WebsocketClient'

  -- Check if related CSK modules are available to be used
  local appList = Engine.listApps()
  for i = 1, #appList do
    if appList[i] == 'CSK_Module_MultiHTTPClient' then
      CSK_MultiWebSocketClient = require 'API.CSK_MultiWebSocketClient'
    end
  end
end

availableAPIs.default = xpcall(loadAPIs, debug.traceback) -- TRUE if all default APIs were loaded correctly
availableAPIs.imageProvider = xpcall(loadSpecificAPIs, debug.traceback) -- TRUE if all specific APIs were loaded correctly
availableAPIs.I2D = xpcall(loadI2DSpecificAPIs, debug.traceback) -- TRUE if all I2D specific APIs were loaded correctly
availableAPIs.GigEVision = xpcall(loadGigEVisionSpecificAPIs, debug.traceback) -- TRUE if all GigE Vision specific APIs were loaded correctly
availableAPIs.SEC100 = xpcall(loadSEC100SpecificAPIs, debug.traceback) -- TRUE if all SEC100 specific APIs were loaded correctly
availableAPIs.SEC100Stream = xpcall(loadSEC100StreamSpecificAPIs, debug.traceback) -- TRUE if all SEC100 specific APIs were loaded correctly

return availableAPIs
--**************************************************************************