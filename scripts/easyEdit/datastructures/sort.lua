
local function get_sort_less_than(field)
	Assert.Equals({'string', 'number'}, type(field), "Argument #1")
	return function(a, b)
		return a[field] < b[field]
	end
end

local function get_sort_greater_than(field)
	Assert.Equals({'string', 'number'}, type(field), "Argument #1")
	return function(a, b)
		return a[field] > b[field]
	end
end

local function get_sort_less_or_equal(field)
	Assert.Equals({'string', 'number'}, type(field), "Argument #1")
	return function(a, b)
		return a[field] <= b[field]
	end
end

local function get_sort_greater_or_equal(field)
	Assert.Equals({'string', 'number'}, type(field), "Argument #1")
	return function(a, b)
		return a[field] >= b[field]
	end
end

return {
	get_sort_less_than = get_sort_less_than,
	get_sort_greater_than = get_sort_greater_than,
	get_sort_less_or_equal = get_sort_less_or_equal,
	get_sort_greater_or_equal = get_sort_greater_or_equal,
}
