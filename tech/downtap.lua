require "/scripts/util.lua"

DownTap = {}

function DownTap:new(validKeys, downkey, downTapTime, tapCallback)
  local newDownTap = {
    downTapTime = downTapTime,
    validKeys = validKeys,
    tapCallback = tapCallback,
    previousKeys = {},
    tapTimer = 0
  }
  setmetatable(newDownTap, extend(self))
  return newDownTap
end

function DownTap:reset()
  self.previousKeys = {}
  self.currentKey = nil
  self.tapTimer = 0
end

function DownTap:update(dt, newKeys)
  if self.currentKey then
    self.tapTimer = math.max(0, self.tapTimer - dt)
    if self.tapTimer == 0 then
      self.currentKey = nil
    elseif newKeys[self.currentKey] and not self.previousKeys[self.currentKey] then
      self.tapCallback(self.currentKey)
      self.currentKey = nil
      return
    end
  end

  for _, key in pairs(self.validKeys) do
    if newKeys[key] and not self.previousKeys[key] then
      self.currentKey = key
      self.tapTimer = self.downTapTime
    end
  end

  self.previousKeys = newKeys
end
