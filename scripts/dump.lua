--https://gist.github.com/stonetoad/64d5d7961b10cd2bacfe

--lua dump function from MrMagical on ##starbound-modding

-- Dumps value as a string closely resemling Lua code that could be used to
-- recreate it (with the exception of functions, threads and recursive tables).
-- 
-- Basic usage: dump(value)
--
-- @param value The value to be dumped.
-- @param indent (optional) String used for indenting the dumped value.
-- @param seen (optional) Table of already processed tables which will be
--                        dumped as "{...}" to prevent infinite recursion.

function dump(value, indent, seen)
  if type(value) ~= "table" then
    if type(value) == "string" then
      return string.format('%q', value)
    else
      return tostring(value)
    end
  else
    if type(seen) ~= "table" then
      seen = {}
    elseif seen[value] then
      return "{...}"
    end
    seen[value] = true
    indent = indent or ""
    if next(value) == nil then
      return "{}"
    end
    local str = "{"
    local first = true
    for k,v in pairs(value) do
      if first then
        first = false
      else
        str = str..","
      end
      str = str.."\n"..indent.."  ".."["..dump(k).."] = "..dump(v, indent.."  ")
    end
    str = str.."\n"..indent.."}"
    return str
  end
end
