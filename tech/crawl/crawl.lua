require "/scripts/vec2.lua"
require "/scripts/dump.lua"

function init()
	sb.logInfo("crawlinit")
	initCommonParameters()
end

function initCommonParameters()
sb.logInfo("crawlinitcomparams")
	self.transformFadeTimer = 0
	self.energyCost = config.getParameter("energyCost")
	self.ballFrames = config.getParameter("ballFrames")
	self.ballSpeed = config.getParameter("ballSpeed")
	self.transformFadeTime = config.getParameter("transformFadeTime", 0.3)
	self.transformedMovementParameters = config.getParameter("transMovementParameters")
	self.transformedMovementParameters.runSpeed = self.ballSpeed
	self.transformedMovementParameters.walkSpeed = self.ballSpeed
	self.basePoly = mcontroller.baseParameters().standingPoly
	self.collisionSet = {"Null", "Block", "Dynamic"}
	self.right = 0
end

function uninit()
	sb.logInfo("crawluninit")
	storePosition()
	deactivate()
end

function update(args)
	restoreStoredPosition()

	if not self.specialLast and args.moves["special"] == 1 then
	  attemptActivation()
	end
	self.specialLast = args.moves["special"] == 1
	
	if self.active then
		mcontroller.controlParameters(self.transformedMovementParameters)
		mcontroller.setRotation(math.pi/2)

	end
	updateTransformFade(args.dt)

	self.lastPosition = mcontroller.position()
end

function attemptActivation()
	sb.logInfo("attemptact")
	if not self.active
	and not tech.parentLounging()
	and not status.statPositive("activeMovementAbilities")
	and status.overConsumeResource("energy", self.energyCost) then
		sb.logInfo("attemptact1")

		local pos = mcontroller.position()
		if pos then
			sb.logInfo("attemptact2")
			mcontroller.setPosition(pos)
			activate()
		end
		elseif self.active then
			sb.logInfo("attemptact3")
			local pos = restorePosition()
			if pos then
      		sb.logInfo("attemptact4")
			mcontroller.setPosition(pos)
			deactivate()
		else
      -- error noise?
		end
	end
end

function storePosition()
	if self.active then
		storage.restorePosition = restorePosition()

  -- try to restore position. if techs are being switched, this will work and the storage will
  -- be cleared anyway. if the client's disconnecting, this won't work but the storage will remain to
  -- restore the position later in update()
		if storage.restorePosition then
			storage.lastActivePosition = mcontroller.position()
			mcontroller.setPosition(storage.restorePosition)
		end
	end
end

function restoreStoredPosition()
  if storage.restorePosition then
      sb.logInfo("restorestored")
    -- restore position if the player was logged out (in the same planet/universe) with the tech active
    if vec2.mag(vec2.sub(mcontroller.position(), storage.lastActivePosition)) < 1 then
      mcontroller.setPosition(storage.restorePosition)
    end
    storage.lastActivePosition = nil
    storage.restorePosition = nil
  end
end
--
--function updateRotationFrame()
--  sb.logInfo("updateRotationFrame")
----  self.angle = math.fmod(math.pi * 2 + self.angle + self.angularVelocity * dt, math.pi * 2)
----
----  -- Rotation frames for the ball are given as one *half* rotation so two
----  -- full cycles of each of the ball frames completes a total rotation.
--  local rotationFrame = math.pi/4
--  animator.setGlobalTag("rotationFrame", rotationFrame)
--end

function updateTransformFade(dt)
  if self.transformFadeTimer > 0 then
  	    sb.logInfo("fadein")
    self.transformFadeTimer = math.max(0, self.transformFadeTimer - dt)
    tech.setParentState("lay")
--    animator.setGlobalTag("ballDirectives", string.format("?fade=FFFFFFFF;%.1f", math.min(1.0, self.transformFadeTimer / (self.transformFadeTime - 0.15))))
  elseif self.transformFadeTimer < 0 then
      sb.logInfo("fadeout")
    self.transformFadeTimer = math.min(0, self.transformFadeTimer + dt)
    tech.setParentDirectives(string.format("?fade=FFFFFFFF;%.1f", math.min(1.0, -self.transformFadeTimer / (self.transformFadeTime - 0.15))))
        tech.setParentDirectives()
  else
--    animator.setGlobalTag("ballDirectives", "")
  end
end

function positionOffset()
  return minY(self.transformedMovementParameters.collisionPoly) - minY(self.basePoly)
end

--function transformPosition(pos)
--  pos = pos or mcontroller.position()
--  local groundPos = world.resolvePolyCollision(self.transformedMovementParameters.collisionPoly, {pos[1], pos[2] - positionOffset()}, 1, self.collisionSet)
--  if groundPos then
--    return groundPos
--  else
--    return world.resolvePolyCollision(self.transformedMovementParameters.collisionPoly, pos, 1, self.collisionSet)
--  end
--end

function restorePosition(pos)
  pos = pos or mcontroller.position()
  local groundPos = world.resolvePolyCollision(self.basePoly, {pos[1], pos[2] + positionOffset()}, 1, self.collisionSet)
  if groundPos then
    return groundPos
  else
    return world.resolvePolyCollision(self.basePoly, pos, 1, self.collisionSet)
  end
end

function activate()
      sb.logInfo("activate")
  if not self.active then
--    animator.burstParticleEmitter("activateParticles")
--    animator.playSound("activate")
--    animator.setAnimationState("ballState", "activate")
    self.angularVelocity = 0
    self.angle = 0
    self.transformFadeTimer = self.transformFadeTime
  end
  tech.setParentHidden(false)
  tech.setParentOffset({0, positionOffset()})
  tech.setToolUsageSuppressed(false)
  status.setPersistentEffects("movementAbility", {{stat = "activeMovementAbilities", amount = 1}})
  self.active = true
end

function deactivate()
      sb.logInfo("deactivate")
  if self.active then
    self.transformFadeTimer = -self.transformFadeTime
  else
--    animator.setAnimationState("ballState", "off")
  end
          tech.setParentState()
    	mcontroller.setRotation(0)
  animator.setGlobalTag("ballDirectives", "")
  tech.setParentHidden(false)
  tech.setParentOffset({0, 0})
--  tech.setToolUsageSuppressed(false)
  status.clearPersistentEffects("movementAbility")
  self.angle = 0
  self.active = false
end

function minY(poly)
  local lowest = 0
  for _,point in pairs(poly) do
    if point[2] < lowest then
      lowest = point[2]
    end
  end
  return lowest
end
