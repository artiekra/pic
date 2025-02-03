-- Base element class
Element = {transforms = {}}
Element.__index = Element


--- Create the object
function Element:new()

  local object = setmetatable({}, self)

  object.transforms = {}

  return object
end


-- Add a transform method with a given name to a class
local function add_transform_method(class, name)

  class[name] = function(self, ...)
    table.insert(self.transforms, {name, {...}})
  end
 
end


add_transform_method(Element, "move")
add_transform_method(Element, "rotate")
add_transform_method(Element, "scale")
add_transform_method(Element, "shear")


return Element
