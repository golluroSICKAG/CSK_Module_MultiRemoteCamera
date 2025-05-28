---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local multiRemoteCameraParameters = {}
  multiRemoteCameraParameters.cameraNo = 1 -- Instance no of this camera (must be set individually)
  multiRemoteCameraParameters.camSum = 1 -- Amount of all cameras (must be set individually)
  multiRemoteCameraParameters.cameraIP = '192.168.1.100' -- IP of camera (must be set individually)

  if _G.availableAPIs.GigEVision == true then
    multiRemoteCameraParameters.gigEvision = true -- Use GigE Vision camera
  else
    multiRemoteCameraParameters.gigEvision = false -- Do not use GigE Vision camera
  end

  multiRemoteCameraParameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  multiRemoteCameraParameters.switchMode = false -- Is camera connected via switch to SIM?
  multiRemoteCameraParameters.shutterTime = 20000 -- Shutter time to use
  multiRemoteCameraParameters.gain = 1.0 -- Gain
  multiRemoteCameraParameters.framerate = 1 -- Frame rate in "FIXED_FREQUENCY" mode
  multiRemoteCameraParameters.acquisitionMode = 'SOFTWARE_TRIGGER' -- 'FIXED_FREQUENCY' / 'SOFTWARE_TRIGGER' / 'HARDWARE_TRIGGER'
  multiRemoteCameraParameters.swTriggerEvent = '' -- Opt. event to trigger camera in SW mode
  multiRemoteCameraParameters.hardwareTriggerDelay = 0 -- Opt. delay for HW trigger
  multiRemoteCameraParameters.triggerDelayBlockName = nil -- Name of specific delay bock within cFlow
  multiRemoteCameraParameters.colorMode = 'MONO8' --'COLOR8' / 'MONO8' / 'RAW8'
  multiRemoteCameraParameters.xStartFOV = 0 -- Field of view xStart
  multiRemoteCameraParameters.xEndFOV = 100 -- Field of view xEnd
  multiRemoteCameraParameters.yStartFOV = 0 -- Field of view yStart
  multiRemoteCameraParameters.yEndFOV = 100 -- Field of view yEnd
  multiRemoteCameraParameters.imagePoolSize = 10 -- Image pool size
  multiRemoteCameraParameters.processingFile = 'CSK_MultiRemoteCamera_ImageProcessing' -- Script to use for processing in thread
  multiRemoteCameraParameters.monitorCamera = false -- Opt. monitor camera status in "CameraOverview" UI
  multiRemoteCameraParameters.customGigEVisionConfig = {} -- Custom GigEVision setting, content are 3 tables ".parameter", ".type", ".value"
  multiRemoteCameraParameters.cameraModel = "PicoMidiCam2" -- 'a2A1920-51gcBAS', 'CustomConfig', 'SEC100'
  multiRemoteCameraParameters.secUser = 'Service' -- User to login to SEC camera
  multiRemoteCameraParameters.secUserPassword = '' -- User password to login to SEC camera
  multiRemoteCameraParameters.secMode = 'Snapshot' -- Mode to run SEC camera

  -- Image processing parameters
  multiRemoteCameraParameters.processingMode = "BOTH" -- 'SCRIPT', 'APP', 'BOTH' --> see "setProcessingMode"
  multiRemoteCameraParameters.maxImageQueueSize = 5 -- max. size of image queue
  multiRemoteCameraParameters.savingImagePath = '/public/' -- path of images to save (SD or public)
  multiRemoteCameraParameters.imageFilePrefix = 'Image_' -- prefix for images to be saved
  multiRemoteCameraParameters.saveAllImages = false -- Save all incoming images
  multiRemoteCameraParameters.tempSaveImage = false -- Save latest image to opt. save it later
  multiRemoteCameraParameters.resizeFactor = 1.0 -- factor to resize the incoming image, 0.1 - 1.0
  multiRemoteCameraParameters.imageSaveFormat = 'bmp' -- bmp / jpg / png
  multiRemoteCameraParameters.imageSaveJpgFormatCompression = 90
  multiRemoteCameraParameters.imageSavePngFormatCompression = 6
  multiRemoteCameraParameters.httpClientInstance = 1 -- Instance of CSK_Module_MultiHTTPClient to use if running SEC100 camera
  multiRemoteCameraParameters.httpClientInterface = 'Localhost' -- Interface to use for HTTP client
  multiRemoteCameraParameters.secWebSocketClientInstance = 1 -- Instance of CSK_Module_MultiWebSocketClient to use if running SEC100 camera in stream mode

  return multiRemoteCameraParameters
end
functions.getParameters = getParameters

return functions