local theentity

function init()
	script.setUpdateDelta(5)
		self.applyDamageRequest =0

end

function update(dt)
	theentity = effect.sourceEntity()
--	sb.logInfo("theentity id#: " .. theentity)
--	sb.logInfo(world.entityPosition(theentity)[1] .. world.entityPosition(theentity)[2])
	thepos = world.entityPosition(theentity)
--	sb.logInfo("thepos       : " .. thepos[1] .. thepos[2])
	if theitems=={} then
		sb.logInfo("bah!")
	end
	theitems = world.itemDropQuery(thepos,2.1)
	if theitems=={} then
		sb.logInfo("bah!")
	end
end
