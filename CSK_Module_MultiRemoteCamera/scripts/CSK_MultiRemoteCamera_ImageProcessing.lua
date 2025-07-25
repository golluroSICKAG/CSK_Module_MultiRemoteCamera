---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
-----------------------------------------------------------

local nameOfModule = 'CSK_MultiRemoteCamera'

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
local availableAPIs = require('Sensors/MultiRemoteCamera/helper/checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device
local json = require('Sensors/MultiRemoteCamera/helper/Json')
-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local scriptParams = Script.getStartArgument() -- Get parameters from model

local cameraNumber = scriptParams:get('cameraNumber') -- camera number of this instance
local cameraNumberString = tostring(cameraNumber) -- number as string
local viewerId = scriptParams:get('viewerId') -- Viewer ID
local lastImage = nil -- holds image to post process (e.g. after changing parameters)
local lastTimestamp = DateTime.getTimestamp() -- timestamp to calculate processing time
local fpsCounter = 0 -- counter to calculate FPS
local secIP = '192.168.136.100' -- IP of SEC100 camera

local queue = Script.Queue.create() -- Queue to stop SEC100 streaming processing if increasing too much
queue:setPriority("MID")
queue:setMaxQueueSize(1)

-- See parameter documenation within Model
local imageProcessingParams = {}
imageProcessingParams.mode = scriptParams:get('mode')
imageProcessingParams.resizeFactor = scriptParams:get('resizeFactor')
imageProcessingParams.maxImageQueueSize = scriptParams:get('maxImageQueueSize')
imageProcessingParams.savingImagePath = scriptParams:get('savingImagePath')
imageProcessingParams.imageFilePrefix = scriptParams:get('imageFilePrefix')
imageProcessingParams.tempSaveImage = scriptParams:get('tempSaveImage')
imageProcessingParams.saveAllImages = scriptParams:get('saveAllImages')
imageProcessingParams.imageSaveFormat = scriptParams:get('imageSaveFormat')
imageProcessingParams.imageSaveJpgFormatCompression = scriptParams:get('imageSaveJpgFormatCompression')
imageProcessingParams.imageSavePngFormatCompression = scriptParams:get('imageSavePngFormatCompression')
imageProcessingParams.httpClientInstance = scriptParams:get('httpClientInstance')
imageProcessingParams.secUser = scriptParams:get('secUser')
imageProcessingParams.secUserPassword = scriptParams:get('secUserPassword')
imageProcessingParams.secMode = scriptParams:get('secMode')
imageProcessingParams.secWebSocketClientInstance = scriptParams:get('secWebSocketClientInstance')

imageProcessingParams.activeInUI = false -- Is this instance currently selected in UI
imageProcessingParams.viewerActive = false -- Should the image be shown in viewer

local viewer = View.create(viewerId) -- Viewer to show image
local imageQueue = Script.Queue.create() -- Queue to stop processing if increasing too much
local jpeg = Image.Format.JPEG.create() -- Image decoder for SEC100 images

-- Event to forward image to other modules
Script.serveEvent("CSK_MultiRemoteCamera.OnNewImageCamera" .. cameraNumberString, "MultiRemoteCamera_OnNewImageCamera" .. cameraNumberString, 'object:1:Image, int:?')

-- Event to forward updated values e.g. through Controller to UI
Script.serveEvent("CSK_MultiRemoteCamera.OnNewValueToForward" .. cameraNumberString, "MultiRemoteCamera_OnNewValueToForward" .. cameraNumberString, 'string:1, auto:1')

--- Function to save incomming image in /public folder of device or on SD card if free space is available
---@param img Image Image to save
local function saveImage(img)
  local compression
  if imageProcessingParams.imageSaveFormat == 'jpg' then
    compression = tostring(imageProcessingParams.imageSaveJpgFormatCompression)
  elseif imageProcessingParams.imageSaveFormat == 'png' then
    compression = tostring(imageProcessingParams.imageSavePngFormatCompression)
  end
  if img ~= nil then
    if imageProcessingParams.savingImagePath == '/public/' then
      local freeSpace = File.getDiskFree("/public")
      if freeSpace >10000000 then
        if not File.isdir("/public/images/camera" .. cameraNumberString) then
          File.mkdir('/public/images/camera' .. cameraNumberString)
        end
        local list = File.list("/public/images/camera" .. cameraNumberString)
        _G.logger:fine(nameOfModule .. ': Try to save new image in public folder from camera No.' .. cameraNumberString)
        local suc
        if list == nil then
          suc = Image.save(img, "public/images/camera" .. cameraNumberString .. "/" .. imageProcessingParams.imageFilePrefix .. "1." .. imageProcessingParams.imageSaveFormat, compression)
        else
          suc = Image.save(img, "public/images/camera" .. cameraNumberString .. "/" .. imageProcessingParams.imageFilePrefix .. tostring(#list+1) .. "." .. imageProcessingParams.imageSaveFormat, compression)
        end
        _G.logger:fine(nameOfModule .. ': Succes of saving new image in public folder:' .. tostring(suc))
      else
        _G.logger:info(nameOfModule .. ": Disk nearly full! Will save no image from camera No." .. cameraNumberString)
      end
    elseif imageProcessingParams.savingImagePath == '/sdcard/0/' then
      if File.isdir("/sdcard/0/") then
        if not File.isdir("/sdcard/0/images/camera" .. cameraNumberString) then
          File.mkdir('/sdcard/0/images/camera' .. cameraNumberString)
        end

        local freeSpace = File.getDiskFree("/sdcard/0/")
        if freeSpace >10000000 then
          local list = File.list("/sdcard/0/images/camera" .. cameraNumberString)
          _G.logger:fine(nameOfModule .. ': Try to save new image on SD card from camera No.' .. cameraNumberString)
          local suc
          if list == nil then
            suc = Image.save(img, "/sdcard/0/images/camera" .. cameraNumberString .. "/" .. imageProcessingParams.imageFilePrefix .. "1." .. imageProcessingParams.imageSaveFormat, compression)
          else
            suc = Image.save(img, "/sdcard/0/images/camera" .. cameraNumberString .. "/" .. imageProcessingParams.imageFilePrefix .. tostring(#list+1) .. "." .. imageProcessingParams.imageSaveFormat, compression)
          end
          _G.logger:fine(nameOfModule .. ': Succes of saving new image on SD card:' .. tostring(suc))
        else
          _G.logger:info(nameOfModule .. ": Disk nearly full! Will save no image from camera No." .. cameraNumberString)
        end
      else
        _G.logger:warning(nameOfModule .. ": NO SD CARD available")
      end
    end
  else
    _G.logger:warning(nameOfModule .. ": No image to save available from camera No." .. cameraNumberString)
  end
end

--- Function to handle incoming images
---@param image Image Image to handle
---@param sensorData SensorData Sensor data
local function handleOnNewImageProcessing(image, sensorData)
  local tic = DateTime.getTimestamp()
  --_G.logger:fine(nameOfModule .. ": New Image cam" .. cameraNumberString) --> For debugging

  -- Release temp Image
  if lastImage ~= nil then
    Script.releaseObject(lastImage)
  end
  local imageQueueSize = imageQueue:getSize()
  if imageProcessingParams.activeInUI == true then
    if (DateTime.getTimestamp() - lastTimestamp) >= 1000 then --> Update only every second
      Script.notifyEvent('MultiRemoteCamera_OnNewValueToForward' .. cameraNumberString, 'MultiRemoteCamera_OnNewImageQueueCamera', tostring(imageQueueSize))
    end
  end

  local resImage = image

  if imageQueueSize >= imageProcessingParams.maxImageQueueSize then
    _G.logger:warning(nameOfModule .. ": Warning! ImageQueue of camera " .. cameraNumberString .. "is >= " .. tostring(imageProcessingParams.maxImageQueueSize) .. "! Stop processing images! Data loss possible...")
  else

    if imageProcessingParams.saveAllImages then
      -- Save image
      saveImage(image)
    elseif imageProcessingParams.tempSaveImage then
      -- Store image to save it if needed.
      lastImage = Object.clone(image)
    end

    if imageProcessingParams.resizeFactor ~= 1.0 then
      -- Resize image
      resImage = Image.resizeScale(image, imageProcessingParams.resizeFactor, imageProcessingParams.resizeFactor, 'LINEAR')
    end

    if imageProcessingParams.mode == 'SCRIPT' or imageProcessingParams.mode == 'BOTH' then
      -- OPTION A --> Using image locally in this script
      if imageProcessingParams.activeInUI == true and imageProcessingParams.viewerActive == true then
        viewer:addImage(resImage)
        viewer:present()
      end
    end

    if imageProcessingParams.mode == 'APP'  or imageProcessingParams.mode == 'BOTH' then

      -- OPTION B --> Forward image to other modules
      _G.logger:fine(nameOfModule .. ": Sending image = " .. cameraNumberString) --> For debugging
      --print("Time till sending image =" .. tostring(DateTime.getTimestamp()-tic)) -- For debugging only
      Script.notifyEvent('MultiRemoteCamera_OnNewImageCamera' .. cameraNumberString, resImage, tic)
    end
  end
  Script.releaseObject(image)
  Script.releaseObject(resImage)

  -- Calculate FPS
  fpsCounter = fpsCounter + 1

  if (DateTime.getTimestamp() - lastTimestamp) >= 1000 then --> Update only every second
    local fps = fpsCounter / ((DateTime.getTimestamp() - lastTimestamp)/1000)
    fpsCounter = 0
    if imageProcessingParams.activeInUI == true then
      Script.notifyEvent('MultiRemoteCamera_OnNewValueToForward' .. cameraNumberString, 'MultiRemoteCamera_OnNewFPSCamera', fps)
    end
    lastTimestamp = DateTime.getTimestamp()
  end
end

--- Function to register on "OnNewImage"-event of image provider
---@param camera handle Image Provider
local function registerCamera(camera)
  _G.logger:fine(nameOfModule .. ": Register camera " .. cameraNumberString)
  Image.Provider.RemoteCamera.register(camera, "OnNewImage", handleOnNewImageProcessing)
  imageQueue:setFunction(handleOnNewImageProcessing)
  Script.releaseObject(camera)
end
Script.register("CSK_MultiRemoteCamera.OnRegisterCamera" .. cameraNumberString, registerCamera)

--- Function to deregister on "OnNewImage"-event of image provider
---@param camera handle Image Provider
local function deregisterCamera(camera)
  _G.logger:fine(nameOfModule .. ": DeRegister camera " .. cameraNumberString)
  Image.Provider.RemoteCamera.deregister(camera, "OnNewImage", handleOnNewImageProcessing)
  imageQueue:clear()
  Script.releaseObject(camera)
end
Script.register("CSK_MultiRemoteCamera.OnDeregisterCamera" .. cameraNumberString, deregisterCamera)

--#############################################
--################### SEC100 ##################
--#############################################

local function buildDigest(_table)
  local hash = Hash.SHA256.create()
  hash:update(table.concat(_table, ":") )
  return hash:getHashValueHex()
end

local function computeResponseHash(challenge, action, user, password)
  local nonce = challenge.nonce
  local ha1, ha2
  if challenge.salt == nil then
    ha1 = buildDigest({user, challenge.realm, password})
  else
    local saltStr = ""
    for _, i in ipairs(challenge.salt) do
        saltStr = saltStr .. string.char(i)
    end
    ha1 = buildDigest({user, challenge.realm, password, saltStr})
  end
  ha2 = buildDigest({"POST", action})
  return buildDigest({ha1, nonce, ha2})
end

--- Function to trigger SEC camera
---@param command string Command to send to SEC camera
---@param data string Data for command
---@return bool suc Success of trigger
local function triggerSEC(command, data)

  local _, challengeResponse = Script.callFunction('CSK_MultiHTTPClient.sendRequest' .. tostring(imageProcessingParams.httpClientInstance), 'POST', 'http://' .. secIP .. '/api/getChallenge', 80, nil, '{"data":{"user": "' .. imageProcessingParams.secUser .. '"}}', 'application/json')
  local challengeResponseContent = json.decode(challengeResponse)
  if challengeResponseContent.Response then

    local response = json.decode(challengeResponseContent.Response)

    if response.challenge then
      local responseHash = computeResponseHash(response.challenge, command, imageProcessingParams.secUser, imageProcessingParams.secUserPassword)
      local requestBody

      if data then
        requestBody = '{"header":{"user":"' .. imageProcessingParams.secUser .. '","response":"' .. responseHash .. '","realm":"SICK Sensor","opaque":"' .. response.challenge.opaque .. '","nonce":"' .. response.challenge.nonce .. '"},' .. data .. '}'
      else
        requestBody = '{"header":{"user":"' .. imageProcessingParams.secUser .. '","response":"' .. responseHash .. '","realm":"SICK Sensor","opaque":"' .. response.challenge.opaque .. '","nonce":"' .. response.challenge.nonce .. '"}}'
      end

      local requestResponse
      local responseData
      if command == 'latestSnapshot' then
        _, requestResponse = Script.callFunction('CSK_MultiHTTPClient.sendRequest' .. tostring(imageProcessingParams.httpClientInstance), 'POST', 'http://' .. secIP .. '/file/download/' .. command, 80, nil, requestBody, 'image/jpeg')
        responseData = json.decode(requestResponse)
        if responseData.StatusCode == 200 then
          local img = jpeg:decode(responseData.Response)
          handleOnNewImageProcessing(img)
          return true
        else
          _G.logger:warning(nameOfModule .. ": Request did not work.")
          return false
        end
      else
        _, requestResponse = Script.callFunction('CSK_MultiHTTPClient.sendRequest' .. tostring(imageProcessingParams.httpClientInstance), 'POST', 'http://' .. secIP .. '/api/' .. command, 80, nil, requestBody, 'application/json')
        responseData = json.decode(requestResponse)
        if responseData.StatusCode ~= 200 then
          _G.logger:warning(nameOfModule .. ": Request did not work.")
          return false
        else
          return true
        end
      end
    else
      _G.logger:warning(nameOfModule .. ": Request challenge did not work.")
      return false
    end
  else
    return false
  end
end

--- Function to unpack image out of binary data (e.g. received by SEC100)
---@param data binary Data
---@param format enum Message format.
local function unpackBinaryImage(data, format)
  if format == 'BINARY' then
    local img = jpeg:decode(data)
    handleOnNewImageProcessing(img)
  end
end
queue:setFunction(unpackBinaryImage)

--#############################################
--################ SEC100 END #################
--#############################################

--- Function to handle updates of processing parameters from Controller
---@param cameraNo int Number of camera instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
local function handleOnNewImageProcessingParameter(cameraNo, parameter, value)
  if parameter == 'viewerActive' then
    imageProcessingParams[parameter] = value
    if value == false then
      viewer:clear()
      viewer:present()
    end
  elseif cameraNo == cameraNumber then
    if parameter == 'saveLastImage' then
      saveImage(lastImage)
    elseif parameter == 'secWebSocketClientInstance' then
      --Script.deregister('CSK_MultiWebSocketClient.OnNewData' .. tostring(imageProcessingParams.secWebSocketClientInstance), unpackBinaryImage)
      imageProcessingParams.secWebSocketClientInstance = value
    elseif parameter == 'SEC100_IP' then
      secIP = value
    elseif parameter == 'secMode' then
      if value == 'Snapshot' then
        local suc = triggerSEC('SnapshotMode', '"data":{"SnapshotMode": 1}')
        if not suc then
          CSK_MultiRemoteCamera.disconnectCamera()
        end
      elseif value == 'Stream' then
        triggerSEC('SnapshotMode', '"data":{"SnapshotMode": 0}')
        local suc = triggerSEC('EventTriggerEvent')
        if not suc then
          CSK_MultiRemoteCamera.disconnectCamera()
        end
        Script.register('CSK_MultiWebSocketClient.OnNewData' .. tostring(imageProcessingParams.secWebSocketClientInstance), unpackBinaryImage)
        queue:setFunction(unpackBinaryImage)
      end
    elseif parameter == 'secStream' then
      if value == false then
        Script.deregister('CSK_MultiWebSocketClient.OnNewData' .. tostring(imageProcessingParams.secWebSocketClientInstance), unpackBinaryImage)
      else
        Script.register('CSK_MultiWebSocketClient.OnNewData' .. tostring(imageProcessingParams.secWebSocketClientInstance), unpackBinaryImage)
        queue:setFunction(unpackBinaryImage)
      end
    elseif parameter == 'SEC100_Trigger' then
      triggerSEC('SnapshotTriggerSnapshot')
      Script.sleep(200)
      triggerSEC('latestSnapshot')
    else
      if not parameter == 'activeInUI' then
        _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of cameraNo." .. tostring(cameraNo) .. " to value = " .. tostring(value))
      end
      imageProcessingParams[parameter] = value
    end
  elseif parameter == 'activeInUI' then
    imageProcessingParams[parameter] = false
    viewer:clear()
    viewer:present()
  end
end
Script.register("CSK_MultiRemoteCamera.OnNewImageProcessingParameter", handleOnNewImageProcessingParameter)
