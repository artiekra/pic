local lerp = {}


--- Linear interpolation between two values
-- Lerp between start and finish value given t
-- @param start start value
-- @param finish finish value
-- @param t cooficient
-- @return the result of the lerp function
function lerp.lerp(start, finish, t)

    -- ensure t is clamped between 0 and 1
    t = math.max(0, math.min(1, t))
    
    return start + (finish - start) * t
end


return lerp
