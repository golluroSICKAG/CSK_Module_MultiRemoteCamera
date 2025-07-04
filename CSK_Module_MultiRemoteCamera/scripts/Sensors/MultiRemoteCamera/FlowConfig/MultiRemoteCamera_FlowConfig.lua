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
    CSK_MultiRemoteCamera.clearFlowConfigRelevantConfiguration()
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)

--- Function to react if FlowConfig was updated
local function handleOnStopProvider()
  if _G.availableAPIs.default and _G.availableAPIs.imageProvider then
    CSK_MultiRemoteCamera.stopFlowConfigRelevantProvider()
  end
end
Script.register('CSK_FlowConfig.OnStopFlowConfigProviders', handleOnStopProvider)
