-- TODO: use inheritance instead
local class_helpers = {}


-- Add a transform method with a given name to a class
local function add_transform_method(class, name)

  class[name] = function(self, ...)
    table.insert(self.transforms, {name, {...}})
  end
 
end


-- Add all the neccesary methods for transforms
-- to the class (element) class
function class_helpers.add_transform_methods(class, name)

  add_transform_method(class, "move")
  add_transform_method(class, "rotate")
  add_transform_method(class, "scale")
  add_transform_method(class, "shear")

end


return class_helpers
