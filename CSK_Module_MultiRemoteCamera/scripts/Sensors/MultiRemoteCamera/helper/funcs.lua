---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find helper functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

local nameOfModule = 'CSK_MultiRemoteCamera'

local funcs = {}
-- Providing standard JSON functions
funcs.json = require('Sensors/MultiRemoteCamera/helper/Json')
-- Default parameters for instances of module
funcs.defaultParameters = require('Sensors/MultiRemoteCamera/MultiRemoteCamera_Parameters')

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Create GigE Vision parameter JSON list for dynamic table
---@param tableType string Type of table
---@param contentA string State of 'ParameterName' or 'No/ParameterNameToConfig/ValueToConfig'
---@param contentB string State of 'Type'
---@param contentC string State of 'Access'
---@param contentD string State of 'Value'
---@return string jsonstring JSON string
local function createModuleJsonList(tableType, contentA, contentB, contentC, contentD)
  local orderedTable = {}
  local list = {}

  if contentA ~= nil then

    for key, value in ipairs(contentA) do
      if tableType == 'gigE' then
        table.insert(list, {ParameterName = value, Type = tostring(contentB[value]), Access = tostring(contentC[value]), Value = tostring(contentD[value])})
      elseif tableType == 'gigEConfig' then
          table.insert(list, {No = tostring(key), ParameterNameToConfig = value['parameter'], ValueToConfig = value['value']})
      end
    end
  end

  if #list == 0 then
    if tableType == 'gigE' then
      list = {{ParameterName = '-', Type = '-', Access = '-', Value = '-'},}
    elseif tableType == 'gigEConfig' then
      list = {{No = '-', ParameterNameToConfig = '-', ValueToConfig = '-'},}
    end
  end

  local jsonstring = funcs.json.encode(list)
  return jsonstring
end
funcs.createModuleJsonList = createModuleJsonList

--- Function to create a list with numbers
---@param size number Size of the list
---@return string list List of numbers
local function createStringListBySize(size)
  local list = "["
  if size >= 1 then
    list = list .. '"' .. tostring(1) .. '"'
  end
  if size >= 2 then
    for i=2, size do
      list = list .. ', ' .. '"' .. tostring(i) .. '"'
    end
  end
  list = list .. "]"
  return list
end
funcs.createStringListBySize = createStringListBySize

-- Function to create a string list for dropdown menu from list of strings
local function createStringListFromList(list)
  local stringList = "["
  local first = true
  for _, entity in ipairs(list) do
    if not first then
      stringList = stringList .. ", "
    end
    first = false
    stringList = stringList .. '"' .. entity .. '"'
  end
  stringList = stringList .. "]"
  return stringList
end
funcs.createStringListFromList = createStringListFromList

--- Function to convert a table into a Container object
---@param content auto[] Lua Table to convert to Container
---@return Container cont Created Container
local function convertTable2Container(content)
  local cont = Container.create()
  for key, value in pairs(content) do
    if type(value) == 'table' then
      cont:add(key, convertTable2Container(value), nil)
    else
      cont:add(key, value, nil)
    end
  end
  return cont
end
funcs.convertTable2Container = convertTable2Container

--- Function to convert a Container into a table
---@param cont Container Container to convert to Lua table
---@return auto[] data Created Lua table
local function convertContainer2Table(cont)
  local data = {}
  local containerList = Container.list(cont)
  local containerCheck = false
  if tonumber(containerList[1]) then
    containerCheck = true
  end
  for i=1, #containerList do

    local subContainer

    if containerCheck then
      subContainer = Container.get(cont, tostring(i) .. '.00')
    else
      subContainer = Container.get(cont, containerList[i])
    end
    if type(subContainer) == 'userdata' then
      if Object.getType(subContainer) == "Container" then

        if containerCheck then
          table.insert(data, convertContainer2Table(subContainer))
        else
          data[containerList[i]] = convertContainer2Table(subContainer)
        end

      else
        if containerCheck then
          table.insert(data, subContainer)
        else
          data[containerList[i]] = subContainer
        end
      end
    else
      if containerCheck then
        table.insert(data, subContainer)
      else
        data[containerList[i]] = subContainer
      end
    end
  end
  return data
end
funcs.convertContainer2Table = convertContainer2Table

--- Function to compare table content. Optionally will fill missing values within content table with values of defaultTable
---@param content auto Data to check
---@param defaultTable auto Reference data
---@return auto[] content Update of data
local function checkParameters(content, defaultTable)
  for key, value in pairs(defaultTable) do
    if type(value) == 'table' then
      if content[key] == nil then
        _G.logger:info(nameOfModule .. ": Created missing parameters table '" .. tostring(key) .. "'")
        content[key] = {}
      end
      content[key] = checkParameters(content[key], defaultTable[key])
    elseif content[key] == nil then
      _G.logger:info(nameOfModule .. ": Missing parameter '" .. tostring(key) .. "'. Adding default value '" .. tostring(defaultTable[key]) .. "'")
      content[key] = defaultTable[key]
      if key == 'cameraNo' then
        _G.logger:warning(nameOfModule .. ": '" .. tostring(key) .. "' is a major parameter! Default value might not work and needs to be edited!")
      end
    end
  end
  return content
end
funcs.checkParameters = checkParameters

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************