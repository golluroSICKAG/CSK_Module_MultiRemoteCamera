-- Block namespace
local BLOCK_NAMESPACE = "MultiRemoteCamera_FC.OnNewImage"
local nameOfModule = 'CSK_MultiRemoteCamera'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

--- Timer to start camera via FlowConfig if in CONTINUOUS (FIXED_FREQUENCY) mode
local tmrStartCamera = Timer.create()
tmrStartCamera:setExpirationTime(5000)
tmrStartCamera:setPeriodic(false)

--- Function to start camera via FlowConig
local function handleOnExpired()
  local amount = CSK_MultiRemoteCamera.getInstancesAmount()
  for i=1, amount do
    CSK_MultiRemoteCamera.setSelectedInstance(i)
    local mode = CSK_MultiRemoteCamera.getAcquisitionMode()
    if mode == 'FIXED_FREQUENCY' then
      CSK_MultiRemoteCamera.startCamera()
    end
  end
end
Timer.register(tmrStartCamera, 'OnExpired', handleOnExpired)

local function register(handle, _ , callback)

  Container.remove(handle, "CB_Function")
  Container.add(handle, "CB_Function", callback)

  local instance = Container.get(handle, 'Instance')

  -- Check if amount of instances is valid
  -- if not: add multiple additional instances
  while true do
    local amount = CSK_MultiRemoteCamera.getInstancesAmount()
    if amount < instance then
      CSK_MultiRemoteCamera.addInstance()
    else
      break
    end
  end

  local function localCallback()
    if callback ~= nil then
      Script.callFunction(callback, 'CSK_MultiRemoteCamera.OnNewImageCamera' .. tostring(instance))
    else
      _G.logger:warning(nameOfModule .. ": " .. BLOCK_NAMESPACE .. ".CB_Function missing!")
    end
  end
  Script.register('CSK_FlowConfig.OnNewFlowConfig', localCallback)

  tmrStartCamera:start()

  return true
end
Script.serveFunction(BLOCK_NAMESPACE ..".register", register)

--*************************************************************
--*************************************************************

local function create(instance)

  -- Check if same instance is already configured
  if instance < 1 or nil ~= instanceTable[instance] then
    _G.logger:warning(nameOfModule .. ': Instance invalid already in use, please choose another one')
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[instance] = instance
    Container.add(handle, 'Instance', instance)
    Container.add(handle, "CB_Function", "")
    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. ".create", create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)