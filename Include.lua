--
-- Ori : Include.lua
--

-- 30log
class = (function()
local next, assert, pairs, type, tostring, setmetatable, baseMt, _instances, _classes, _class = next, assert, pairs, type, tostring, setmetatable, {}, setmetatable({},{__mode = 'k'}), setmetatable({},{__mode = 'k'})
local function assert_call_from_class(class, method) assert(_classes[class], ('Wrong method call. Expected class:%s.'):format(method)) end; local function assert_call_from_instance(instance, method) assert(_instances[instance], ('Wrong method call. Expected instance:%s.'):format(method)) end
local function bind(f, v) return function(...) return f(v, ...) end end
local default_filter = function() return true end
local function deep_copy(t, dest, aType) t = t or {}; local r = dest or {}; for k,v in pairs(t) do if aType ~= nil and type(v) == aType then r[k] = (type(v) == 'table') and ((_classes[v] or _instances[v]) and v or deep_copy(v)) or v elseif aType == nil then r[k] = (type(v) == 'table') and k~= '__index' and ((_classes[v] or _instances[v]) and v or deep_copy(v)) or v end; end return r end
local function instantiate(call_init,self,...) assert_call_from_class(self, 'new(...) or class(...)'); local instance = {class = self}; _instances[instance] = tostring(instance); deep_copy(self, instance, 'table')instance.__index, instance.__subclasses, instance.__instances, instance.mixins = nil, nil, nil, nil; setmetatable(instance,self); if call_init and self.init then if type(self.init) == 'table' then deep_copy(self.init, instance) else self.init(instance, ...) end end; return instance end
local function extend(self, name, extra_params)assert_call_from_class(self, 'extend(...)'); local heir = {}; _classes[heir] = tostring(heir); self.__subclasses[heir] = true; deep_copy(extra_params, deep_copy(self, heir))heir.name, heir.__index, heir.super, heir.mixins = extra_params and extra_params.name or name, heir, self, {}; return setmetatable(heir,self)end
baseMt = { __call = function (self,...) return self:new(...) end, __tostring = function(self,...)if _instances[self] then return ("instance of '%s' (%s)"):format(rawget(self.class,'name') or '?', _instances[self]) end; return _classes[self] and ("class '%s' (%s)"):format(rawget(self,'name') or '?', _classes[self]) or self end
}; _classes[baseMt] = tostring(baseMt); setmetatable(baseMt, {__tostring = baseMt.__tostring})
local class = {isClass = function(t) return not not _classes[t] end, isInstance = function(t) return not not _instances[t] end}
_class = function(name, attr) local c = deep_copy(attr); _classes[c] = tostring(c)
	c.name, c.__tostring, c.__call, c.new, c.create, c.extend, c.__index, c.mixins, c.__instances, c.__subclasses = name or c.name, baseMt.__tostring, baseMt.__call, bind(instantiate, true), bind(instantiate, false), extend, c, setmetatable({},{__mode = 'k'}), setmetatable({},{__mode = 'k'}), setmetatable({},{__mode = 'k'})
	c.subclasses = function(self, filter, ...) assert_call_from_class(self, 'subclasses(class)'); filter = filter or default_filter; local subclasses = {}; for class in pairs(_classes) do if class ~= baseMt and class:subclassOf(self) and filter(class,...) then subclasses[#subclasses + 1] = class end end; return subclasses end
	c.instances = function(self, filter, ...) assert_call_from_class(self, 'instances(class)'); filter = filter or default_filter; local instances = {}; for instance in pairs(_instances) do if instance:instanceOf(self) and filter(instance, ...) then instances[#instances + 1] = instance end end; return instances end
	c.subclassOf = function(self, superclass) assert_call_from_class(self, 'subclassOf(superclass)'); assert(class.isClass(superclass), 'Wrong argument given to method "subclassOf()". Expected a class.'); local super = self.super; while super do if super == superclass then return true end; super = super.super end; return false end
	c.classOf = function(self, subclass) assert_call_from_class(self, 'classOf(subclass)'); assert(class.isClass(subclass), 'Wrong argument given to method "classOf()". Expected a class.'); return subclass:subclassOf(self) end
	c.instanceOf = function(self, fromclass) assert_call_from_instance(self, 'instanceOf(class)'); assert(class.isClass(fromclass), 'Wrong argument given to method "instanceOf()". Expected a class.'); return ((self.class == fromclass) or (self.class:subclassOf(fromclass))) end
	c.cast = function(self, toclass) assert_call_from_instance(self, 'instanceOf(class)'); assert(class.isClass(toclass), 'Wrong argument given to method "cast()". Expected a class.'); setmetatable(self, toclass); self.class = toclass; return self end
	c.with = function(self,...) assert_call_from_class(self, 'with(mixin)'); for _, mixin in ipairs({...}) do assert(self.mixins[mixin] ~= true, ('Attempted to include a mixin which was already included in %s'):format(tostring(self))); self.mixins[mixin] = true; deep_copy(mixin, self, 'function') end return self end
	c.includes = function(self, mixin) assert_call_from_class(self,'includes(mixin)'); return not not (self.mixins[mixin] or (self.super and self.super:includes(mixin))) end	
	c.without = function(self, ...) assert_call_from_class(self, 'without(mixin)'); for _, mixin in ipairs({...}) do
		assert(self.mixins[mixin] == true, ('Attempted to remove a mixin which is not included in %s'):format(tostring(self))); local classes = self:subclasses(); classes[#classes + 1] = self
		for _, class in ipairs(classes) do for method_name, method in pairs(mixin) do if type(method) == 'function' then class[method_name] = nil end end end; self.mixins[mixin] = nil end; return self end; return setmetatable(c, baseMt) end
class._DESCRIPTION = '30 lines library for object orientation in Lua'; class._VERSION = '30log v1.2.0'; class._URL = 'http://github.com/Yonaba/30log'; class._LICENSE = 'MIT LICENSE <http://www.opensource.org/licenses/mit-license.php>' setmetatable(class,{__call = function(_,...) return _class(...) end })
return class
	end)()

-- new function
new = function(InstanceClass, InstanceParent, ...)
	-- Check if the arguments are correct
	local InstanceClassType = type(InstanceClass)
	local InstanceParentType = typeof(InstanceParent)
	assert(InstanceClassType == "nil" or InstanceClassType == "string", "Expected string at argument #1, got " .. InstanceClassType)
	assert(InstanceParentType == "nil" or InstanceParentType == "Instance", "Expected Instance at argument #2, got " .. InstanceParentType)
	
	-- Create instance
	local ReturnedInstance
		local SUCCESS, RETURN = pcall(function()
			ReturnedInstance = Instance.new(InstanceClass)
		end)
	if not SUCCESS then
		error(InstanceClass .. " is not a valid ClassName: " .. debug.traceback())
		return nil
	end
	ReturnedInstance.Parent = InstanceParent
	
	-- Change properties of the Instance
	local ArgumentProperties = {...}
	local SetProperties = {}
	
	for ArgumentIndex, Argument in ipairs(ArgumentProperties) do
			-- Check if 'Argument' is a table
		local ArgumentType = type(Argument)
		assert(ArgumentType == "table", "Expected table at argument #" .. tostring(ArgumentIndex + 2) .. ", got " .. ArgumentType)
			--
		for PropertyName, Property in pairs(Argument) do
			SetProperties[PropertyName] = Property
		end
	end
	
	for PropertyName, Property in pairs(SetProperties) do
		local SUCCESS, RETURN = pcall(function()
			ReturnedInstance[PropertyName] = Property
		end)
		
		if not SUCCESS then
			error("Error trying to set property '" .. PropertyName .. "' to Instance " .. InstanceClass .. " (Property type is " .. type(PropertyValue) .. ") ")
		end
	end
	
	return ReturnedInstance
end

-- newEvent
function newEvent()
    return {
        Bin = Instance.new("BindableEvent"),
        
        Fire = function(self, ...)
            self.Bin:Fire()
            return self
        end,
        
        Connect = function(self, ...)
            return self.Bin.Event:Connect(...)
        end,
        
        Wait = function(self, ...)
            return self.Bin.Event:Wait()
        end
    }
end
--

-- addCornerRadius function
function addCornerRadius(instance, amount)
	local instanceType, amountType = typeof(instance), type(amount)
	assert(instanceType == "Instance", ("addCornerRadius, Instance expected at argument #1, got %s"):format(instanceType))
	assert(amountType == "number", ("addCornerRadius, number expected at argument #2, got %s"):format(amountType))
	
	return new("UICorner", instance, {CornerRadius = UDim.new(0, amount)})
end

-- addPadding function
function addPadding(instance, padding)
	local instanceType, paddingType = typeof(instance), type(padding)
	assert(instanceType == "Instance", ("addPadding, Instance expected at argument #1, got %s"):format(instanceType))
	assert(paddingType == "table", ("addPadding, table expected at argument #2, got %s"):format(paddingType))
	
	return new("UIPadding", instance, {
		PaddingLeft = UDim.new(0, padding.left or 0),
		PaddingTop = UDim.new(0, padding.top or 0),
		PaddingRight = UDim.new(0, padding.right or 0),
		PaddingBottom = UDim.new(0, padding.bottom or 0),
		})
end

-- addListLayout
function addListLayout(instance, padding)
	local instanceType, paddingType = typeof(instance), type(padding)
	assert(instanceType == "Instance", ("addListLayout, Instance expected at argument #1, got %s"):format(instanceType))
	assert(paddingType == "number", ("addListLayout, number expected at argument #2, got %s"):format(paddingType))
	
	return new("UIListLayout", instance, {Padding = UDim.new(0, padding), SortOrder = Enum.SortOrder.LayoutOrder})
end
