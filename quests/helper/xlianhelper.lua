require("/quests/scripts/portraits.lua")
require("/quests/scripts/questutil.lua")
require("/scripts/actions/dialog.lua")
require "/scripts/vec2.lua"
require "/scripts/dump.lua"
function getAllData(t, prevData)
  -- if prevData == nil, start empty, otherwise start with prevData
  local data = prevData or {}

  -- copy all the attributes from t
  for k,v in pairs(t) do
    data[k] = data[k] or v
  end

  -- get t's metatable, or exit if not existing
  local mt = getmetatable(t)
  if type(mt)~='table' then return data end

  -- get the __index from mt, or exit if not table
  local index = mt.__index
  if type(index)~='table' then return data end

  -- include the data from index into data, recursively, and return
  return getAllData(index, data)
end

local locationhack = true

--function positionOffset()
--  return minY(self.transformedMovementParameters.collisionPoly) - minY(self.basePoly)
--end

function init()
	sb.logInfo("We're in.")
	locationhack = true
	sb.logInfo("entspecies: " .. dump(world.entitySpecies(entity.id())))
	sb.logInfo("isplayer  : " .. dump(world.entitySpecies(entity.id())))
	self.pesterTimer = 0
	if world.entitySpecies(entity.id()) == "xlian" then
		sb.logInfo("yes")
		status.addEphemeralEffect("racexlian",math.huge)
		if world.entityType(entity.id()) == "player" then
			sb.logInfo("yes")
			status.addEphemeralEffect("racexlianplayer",math.huge)
		end
	end
--	sb.logInfo(dump(player))
end

function questStart()
	sb.logInfo("Showtime!")
end

function questComplete()
	sb.logError("This shouldn't have happened. Why did it happen?")
end

function update(dt)
	if not player.isLounging() and locationhack and mcontroller.canJump() and mcontroller.isCollisionStuck() then
		mcontroller.setYPosition(mcontroller.yPosition()+6)
		locationhack = false
--		sb.logInfo(mcontroller.isCollisionStuck())
	end
--	sb.logInfo("Tee hee!")
--	tech = "distortionsphere"
	tech = "crawl"
	player.makeTechAvailable(tech)
    player.enableTech(tech)
    player.equipTech(tech)
    
--	tech = "doublejump2"
--	player.makeTechAvailable(tech)
--    player.enableTech(tech)
--    player.equipTech(tech)
--
--	sb.logInfo(dump(mcontroller.canJump()))

	updatePester(dt)
	chestose=hasEquippedoversized("chest")
--	sb.logInfo("FDFfD")
	cosmchestose=hasEquippedoversized("chestCosmetic")
	legose=hasEquippedoversized("legs")
	cosmlegose=hasEquippedoversized("legsCosmetic")
end

function uninit()
	sb.logInfo("Xlian Helper quest uninit")
end

function hasUniform()
  return player.hasItem("protectoratechest") and player.hasItem("protectoratepants")
end


function hasEquippedUniform()
	local chestItem = player.equippedItem("chest")
	local chestCosmeticItem = player.equippedItem("chestCosmetic")
	local legsItem = player.equippedItem("legs")
	local legsCosmeticItem = player.equippedItem("legsCosmetic")
	
	

	return ((chestItem and chestItem.name == "protectoratechest") or
		(chestCosmeticItem and chestCosmeticItem.name == "protectoratechest")) and
		((legsItem and legsItem.name == "protectoratepants") or
		(legsCosmeticItem and legsCosmeticItem.name == "protectoratepants"))
end

function takeoff(slot,slotItem)
	sb.logInfo("take it off!")
	player.radioMessage("toosmall")
	player.giveItem(slotItem)
	player.setEquippedItem(slot,"")
end

function hasEquippedoversized(slot)
	local isoversized = false
--	sb.logInfo(slot)
	local slotItem = player.equippedItem(slot)
--	sb.logInfo("FfDFD")
	if slotItem ~=nil  then
		tags = root.itemConfig(slotItem).config.itemTags
		if tags ~=nil  then
	 	   for k in pairs(root.itemConfig(slotItem).config.itemTags) do
	    		if root.itemConfig(slotItem).config.itemTags[k] == "oversized" then
	    			isoversized = true
	    			break
	    		end
			end
--	    	sb.logInfo("breaknot")
		end
		if not isoversized then
			takeoff(slot,slotItem)
			player.radioMessage("toosmall",1)
		end
	end
	return isoversized
end

function setPester(messageId, timeout)
  self.pesterMessage = messageId
  self.pesterTimer = timeout or 0
end

function updatePester(dt)
  if self.pesterTimer > 0 then
    self.pesterTimer = self.pesterTimer - dt
    if self.pesterTimer <= 0 then
      player.radioMessage(self.pesterMessage)
    end
  end
end
