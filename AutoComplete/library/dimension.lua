---@meta


---@class dimension
dimension = {}


---The numerical identifier of the dimension
---0 == Overworld
---1 == Nether
---2 == TheEnd
---@return number id The dimension id of the current dimension
function dimension.id() end


---The name of the dimension
---The default dimensions are:
---"Overworld"
---"Nether"
---"TheEnd"
---@return string name
function dimension.name() end

---The time in the dimension
---Ranges from 0 to 1, 0 is the start of the day 0.5 is night and 1 is the end of the day will wrap to 0
---@return number time The current time in the dimension
function dimension.time() end

---Will return true if it is currently raining
---@return boolean isRaining Is it raining right now?
function dimension.isRaining() end

---Plays a sound at these coordinates
---Will not work on 1.18.30+
---@param x integer | number The x position
---@param y integer | number The y position
---@param z integer | number The z position
---@param name string any minecraft sounds: https://www.digminecraft.com/lists/sound_list_pe.php
function dimension.sound(x, y, z, name) end

---@class LightPair
---@field blockLight integer The light level caused by torches and stuff
---@field skyLight integer The light level of the environement (will not adapt to time)


---@class Block
---@field id integer The numerical identifier of the block (changes with versions)
---@field data integer The data of the block: example the color of the wool in a /setblock
---@field name string The name that would be used in /setblock
---@field state table The block state
---@field hash integer Unique hash for the block (not including state)

---@class Biome
---@field id integer The numerical identifier of the biome (might change with versions)
---@field name string The name of the biome
---@field temperature number The temperature of the biome
---@field snow boolean Can it snow in that biome
---@field canRain boolean Can it rain in that biome

---@class BiomeColorData
---@field grass ColorSetting The color of the grass
---@field water ColorSetting The color of the water 

---Gets the light levels of these coordinates
---The highest between sky and block is the real brightness
---note that as the sun goes down this number will not change
---@param x integer | number The x position
---@param y integer | number The y position
---@param z integer | number The z position
---@return LightPair lightPair The light level
function dimension.getBrightness(x, y, z) end

---Gets the block at these coordinates
---@param x integer | number The x position
---@param y integer | number The y position
---@param z integer | number The z position
---@return Block block The block information
function dimension.getBlock(x, y, z) end

---Finds a block among the world 
---local positons = result[1] change the 1 to whatever index you wish to use! you can use the # operator to get the size (#result)
---@param name string The name of the block
---@return integer[][] blockPositions The block information
function dimension.findBlock(name) end

---Finds a block among the world 
---local positons = result[1] change the 1 to whatever index you wish to use! you can use the # operator to get the size (#result)
---@param name string The name of the block
---@param blockData integer | number The data of the block
---@return integer[][] blockPositions The block information
function dimension.findBlock(name, blockData) end

---Finds a block among the world 
---local positons = result[1] change the 1 to whatever index you wish to use! you can use the # operator to get the size (#result)
---@param name string The name of the block
---@param blockData integer | number The data of the block
---@param radius integer | number The radius to search in (will be chunk aligned to then center of the chunk
---@return integer[][] blockPositions The block information
function dimension.findBlock(name, blockData, radius) end

---Finds a block among the world 
---local positons = result[1] change the 1 to whatever index you wish to use! you can use the # operator to get the size (#result)
---@param name string The name of the block
---@param blockData integer | number The data of the block
---@param radius integer | number The radius to search in (will be chunk aligned to then center of the chunk
---@param x integer | number The x center position
---@param y integer | number The y center position
---@param z integer | number The z center position
---@return integer[][] blockPositions The block information
function dimension.findBlock(name, blockData, radius, x, y, z) end

---Finds a block among the world 
---local x,y,z = result[1] change the 1 to whatever index you wish to use! you can use the # operator to get the size (#result)
---@param x integer | number The x center position
---@param y integer | number The y center position
---@param z integer | number The z center position
---@return BiomeColorData colorData The color of the water and grass at this x,z
function dimension.getBiomeColor(x, y, z) end

---Gets the block at these coordinates
---@param x integer | number The x position
---@param y integer | number The y position
---@param z integer | number The z position
---@return table blockEntity The NBT of the block entity
function dimension.getBlockEntity(x, y, z) end

---Gets the block entity nbt at these coordinates
---@param x integer | number The x position
---@param y integer | number The y position
---@param z integer | number The z position
---@param getServerSideEntity boolean Should we get the server one (unstable outside of the LocalServerUpdate event)
---@return table blockEntity The NBT of the block entity
function dimension.getBlockEntity(x, y, z, getServerSideEntity) end

---Gets the biome at these coordinates
---@param x integer | number The x position
---@param y integer | number The y position
---@param z integer | number The z position
---@return Biome biome The biome information
function dimension.getBiome(x, y, z) end


---Gets the color that would show on a minecraft map
---@param x integer | number The x position
---@param y integer | number The y position
---@param z integer | number The z position
---@return integer r The red part of the color
---@return integer g The green part of the color
---@return integer b The blue part of the color
---@return integer a The opacity part of the color
function dimension.getMapColor(x,y,z) end


---@class RaycastInfo
---@field x integer The x position of the hit block
---@field y integer The y position of the hit block
---@field z integer The z position of the hit block
---@field px number The precise x position on the block where the hit happened
---@field py number The precise y position on the block where the hit happened
---@field pz number The precise z position on the block where the hit happened
---@field isEntity boolean If the raycast hit an entity
---@field isBlock boolean If the raycast hit a block
---@field blockFace integer What face of a block did the raycast hit



---Casts a ray in the world between two points
---Traces a line in the world hoping or not to hit a block
---@param startX number The x start position
---@param startY number The y start position
---@param startZ number The y start position
---@param endX number the x end position, where are we going
---@param endY number the y end position, where are we going
---@param endZ number the z end position, where are we going
---@return RaycastInfo hit The result of the raycast
function dimension.raycast(startX, startY, startZ, endX, endY, endZ) end

---Casts a ray in the world between two points
---Traces a line in the world hoping or not to hit a block
---@param startX number The x start position
---@param startY number The y start position
---@param startZ number The y start position
---@param endX number the x end position, where are we going
---@param endY number the y end position, where are we going
---@param endZ number the z end position, where are we going
---@param maxDistance integer (default: distance between start and stop) Maximum distance to travel before giving up (lower values can make no hit waste less time)
---@return RaycastInfo hit The result of the raycast
function dimension.raycast(startX, startY, startZ, endX, endY, endZ, maxDistance) end

---Casts a ray in the world between two points
---Traces a line in the world hoping or not to hit a block
---@param startX number The x start position
---@param startY number The y start position
---@param startZ number The y start position
---@param endX number the x end position, where are we going
---@param endY number the y end position, where are we going
---@param endZ number the z end position, where are we going
---@param maxDistance integer (default: distance between start and stop) Maximum distance to travel before giving up (lower values can make no hit waste less time)
---@param hitLiquid boolean (default: false) If don't want to go through liquid make this true
---@return RaycastInfo hit The result of the raycast
function dimension.raycast(startX, startY, startZ, endX, endY, endZ, maxDistance, hitLiquid) end

---Casts a ray in the world between two points
---Traces a line in the world hoping or not to hit a block
---@param startX number The x start position
---@param startY number The y start position
---@param startZ number The y start position
---@param endX number the x end position, where are we going
---@param endY number the y end position, where are we going
---@param endZ number the z end position, where are we going
---@param maxDistance integer (default: distance between start and stop) Maximum distance to travel before giving up (lower values can make no hit waste less time)
---@param hitLiquid boolean (default: false) If don't want to go through liquid make this true
---@param solidBlocksOnly boolean (default: true) Will ignore things like grass, flowers, etc that you can walk through
---@return RaycastInfo hit The result of the raycast
function dimension.raycast(startX, startY, startZ, endX, endY, endZ, maxDistance, hitLiquid, solidBlocksOnly) end

---Casts a ray in the world between two points
---Traces a line in the world hoping or not to hit a block
---@param startX number The x start position
---@param startY number The y start position
---@param startZ number The y start position
---@param endX number the x end position, where are we going
---@param endY number the y end position, where are we going
---@param endZ number the z end position, where are we going
---@param maxDistance integer (default: distance between start and stop) Maximum distance to travel before giving up (lower values can make no hit waste less time)
---@param hitLiquid boolean (default: false) If don't want to go through liquid make this true
---@param solidBlocksOnly boolean (default: true) Will ignore things like grass, flowers, etc that you can walk through
---@param fullBlocksOnly boolean (default: false) not certain, probably wont go through opened trapdoors and that kindof stuff
---@return RaycastInfo hit The result of the raycast
function dimension.raycast(startX, startY, startZ, endX, endY, endZ, maxDistance, hitLiquid, solidBlocksOnly, fullBlocksOnly) end
