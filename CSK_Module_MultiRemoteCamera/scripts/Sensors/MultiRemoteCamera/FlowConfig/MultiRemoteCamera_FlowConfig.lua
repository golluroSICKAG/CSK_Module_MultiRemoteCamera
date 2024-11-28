--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Sensors.MultiRemoteCamera.FlowConfig.MultiRemoteCamera_OnNewImage')

-- Reference to the multiRemoteCamera_Instances handle
local multiRemoteCamera_Instances

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.imageProvider then
    for i = 1, #multiRemoteCamera_Instances do
      if multiRemoteCamera_Instances[i].parameters.flowConfigPriority then
        CSK_MultiRemoteCamera.clearFlowConfigRelevantConfiguration()
        break
      end
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)

--- Function to get access to the multiRemoteCamera_Instances
---@param handle handle Handle of multiRemoteCamera_Instances object
local function setMultiRemoteCamera_Instances_Handle(handle)
  multiRemoteCamera_Instances = handle
end

return setMultiRemoteCamera_Instances_Handle