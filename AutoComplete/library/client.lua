---@diagnostic disable: duplicate-set-field
---@meta


---@class client
---@field version string The client version
---@field mcversion string The minecraft version
client = client or {}

---Sends a client notification
---@param text string The text in the notification
function client.notification(text) end

---Gets the game's language
---@return string languageCode The language code, example: en_US
function client.language() end

---Executes a client command, do not include the prefix
---You may use the execute command to do minecraft commands
---Example: client.execute("execute /say imbald")
---@param command string The command without the prefix
function client.execute(command) end


---@class Waypoint
---@field x integer The x position of the waypoint
---@field y integer The y position of the waypoint
---@field z integer The z position of the waypoint
---@field name string The name of the waypoint
---@field dimensionId integer The dimension id the waypoint is for



---@class Waypoints
local _acp__Waypoints_ = {}

---Gets the list of waypoint
---@return Waypoint[]
function _acp__Waypoints_.get() end

---Adds a waypoint
---@param x integer The x position of the waypoint
---@param y integer The y position of the waypoint
---@param z integer The z position of the waypoint
---@param name string The name of the waypoint
function _acp__Waypoints_.add(x, y, z, name) end

---Adds a waypoint with a dimension id (overworld 0, nether 1, overworld 2)
---@param x integer The x position of the new waypoint
---@param y integer The y position of the new waypoint
---@param z integer The z position of the new waypoint
---@param name string The name of the new waypoint
---@param dimensionId integer In what dimension is the mew waypoint
---@return boolean added If the waypoint has been added or not
function _acp__Waypoints_.add(x, y, z, name, dimensionId) end

---Removes a waypoint by its name
---@param name string The name of the waypoint to remove
---@return boolean added If the waypoint has been removed or not
function _acp__Waypoints_.remove(name) end

---Removes a waypoint by its position
---@param x integer The x position of the waypoint to remove
---@param y integer The y position of the waypoint to remove
---@param z integer The z position of the waypoint to remove
---@return boolean added If the waypoint has been removed or not
function _acp__Waypoints_.remove(x, y, z) end

---Saves the waypoint list to file
function _acp__Waypoints_.save() end
---Loads the waypoint list to file
function _acp__Waypoints_.load() end

---Clears all waypoints
function _acp__Waypoints_.clear() end

---Gets the waypoints
---@return Waypoints
function client.waypoints() end


---@class ClientConfig
---@field name string The name of the config
---@field exists boolean If this config exists on disk

---@class ConfigManager
local _acp__ConfigManager_ = {}

---Gets a config from its name
---@param name string The name
---@return ClientConfig clientConfig The config you wanted (check if it exists if thats important)
function _acp__ConfigManager_:get(name) end

---Gets the active config (Could differ from default)
---@return ClientConfig clientConfig The active config
function _acp__ConfigManager_:getActive() end

---Gets the default config (the one that will be loaded on inject)
---@return ClientConfig clientConfig The default config
function _acp__ConfigManager_:getDefault() end

---Sets the default config (the one that will be loaded on inject)
---@param config ClientConfig The config to set as default
function _acp__ConfigManager_:setDefault(config) end

---Checks to see if a config is the default one or not
---@param config ClientConfig The config you want to know if its the default one or not
function _acp__ConfigManager_:isDefault(config) end

---Checks to see if a config is the active one or not
---@param config ClientConfig The config you want to know if its the active one or not
function _acp__ConfigManager_:isActive(config) end

---Gets a list of client configs
---@return ClientConfig[] clientConfig List of existing configs at the time of the request
function _acp__ConfigManager_:list() end

---Deletes a config
---@param config ClientConfig the config to delete
function _acp__ConfigManager_:delete(config) end

---Creates a new config with default settings on everything
---@param config ClientConfig The config to create
function _acp__ConfigManager_:new(config) end

---Saves the current config to a config
---@param config ClientConfig The config to save into
function _acp__ConfigManager_:save(config) end

---Loads a config
---@param config ClientConfig The config to load
function _acp__ConfigManager_:load(config) end

---Gets the config manager that can do various config things
---@return ConfigManager configManager The client config manager
function client.getConfigManager() end

---Gets the config manager that can do various config things that could be for scripting
---@param scripting boolean (default: false) Get the scripting version of the Config Manager?
---@return ConfigManager configManager The client config manager
function client.getConfigManager(scripting) end





---@class Vector2
---@field x number
---@field y number




---@class ColorSetting
---@field r number The amount of Red from a range of 0 to 1
---@field g number The amount of Green from a range of 0 to 1
---@field b number The amount of Blue from a range of 0 to 1
---@field a number The amount of Opacity from a range of 0 to 1
---@field alphaVisible boolean alphaVisible Should the opacity slider be availible
---@field rainbow boolean Is this color rainbow
---@field rainbowSpeed number The speed of the rainbow effect (default=0.003)


---@class Setting
---@field type integer
---@field name string The display name of the setting
---@field saveName string The name used to save/load this Setting, no spaces
---@field visible boolean Should show in the ui
---@field value boolean|integer|number|Vector2|ColorSetting The value of the setting
---@field default boolean|integer|number|Vector2|ColorSetting The default value of the setting
---@field min integer|number|Vector2|nil Minimum value of the setting
---@field max integer|number|Vector2|nil Maximum value of the setting
---@field scale number The scale of info settings
---@field parent Module the parent module
---@field enumValues table[] table of tables, e.g. { {integerValue, uiName}, {otherIntValue, uiName} }








---@class Module
---@field name string The name of the module
---@field description string The description of the module
---@field isVisual boolean if the module is a VisualModule
---@field isTextual boolean if the module is a TextualModule
---@field isScript boolean if the module is a ScriptingModule
---@field visible boolean if the module is visible in the clickgui
---@field enabled boolean [you can set] if the module is enabled
---@field settings Setting[] A list with all the module's settings
local _acp__Module_ = {}

---Remove a setting from the mod
---@param setting Setting the setting to remove from the mod
function _acp__Module_.removeSetting(setting) end


---@class VisualModule : Module
---@field size Vector2 The size of the module
---@field pos Vector2 The position of the module
---@field relativepos Vector2 The relative position of the module (relative from anchor position)
---@field anchor integer 0 = Invalid, 1 = Top Left, 2 = Top Right, 3 = Bottom Left, 4 = Bottom Right

---@class ScriptingModule : Module
---@field movable boolean If the module is movable
---@field scale number The scale of the module
---@field size Vector2 The size of the module
---@field pos Vector2 The position of the module

---@class TextualModule : VisualModule
---@field text string The text of the module




---Gets a list of all the modules in the client
---@return Module[] | VisualModule[] | ScriptingModule[] Could be any mix of those 3 types
function client.modules() end


