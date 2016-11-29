require("/scripts/vec2.lua")

--function table.val_to_str ( v )
--  if "string" == type( v ) then
--    v = string.gsub( v, "\n", "\\n" )
--    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
--      return "'" .. v .. "'"
--    end
--    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
--  else
--    return "table" == type( v ) and table.tostring( v ) or
--      tostring( v )
--  end
--end
--
--function table.key_to_str ( k )
--  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
--    return k
--  else
--    return "[" .. table.val_to_str( k ) .. "]"
--  end
--end
--
--function table.tostring( tbl )
--  local result, done = {}, {}
--  for k, v in ipairs( tbl ) do
--    table.insert( result, table.val_to_str( v ) )
--    done[ k ] = true
--  end
--  for k, v in pairs( tbl ) do
--    if not done[ k ] then
--      table.insert( result,
--        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
--    end
--  end
--  return "{" .. table.concat( result, "," ) .. "}"
--end
--
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function init()
	
end

function update(dt)
	theentity = effect.sourceEntity()
--	sb.logInfo("assf")
--	sb.logInfo("theentity id#: " .. theentity)
	thepos = world.entityPosition(theentity)
--	sb.logInfo("theposi      : " .. thepos[1].. ", " .. thepos[2])
	theitems = world.itemDropQuery(thepos,8.0,{boundMode="position"})
--	sb.logInfo("ssfdf" .. table.tostring(theitems) .. "  " .. tablelength(theitems))
	if tablelength(theitems) > 0 then
		world.spawnProjectile("hgravityexplosion2",mcontroller.position(),entity.id(),{0,0},true,configBombDrop);
	end
--	effect.setParentDirectives("?multiply=FFFFFF00?blendscreen=/interface/cockpit/initiatejumpover.png")
end

function uninit()
	
end