
deco.colors.healthgreen = sdl.rgb(50, 255, 50)

function get_element(item, list)
	for i = 1, #list do
		if list[i] == item then
			return list, i
		end
	end
end

function clear_table(list)
	for i, _ in pairs(list) do
		list[i] = nil
	end
end

function clone_table(list, template)
	for i, v in pairs(template) do
		list[i] = v
	end
end

function last_entry(list)
	return list[#list]
end

function table_indexof(tbl, value)
	for k, v in ipairs(tbl) do
		if value == v then
			return k
		end
	end

	return -1
end

function max(...)
	local largest = -INT_MAX

	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value > largest then
			largest = value
		end
	end

	return largest
end

function min(...)
	local smallest = INT_MAX

	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value < smallest then
			smallest = value
		end
	end

	return largest
end

function table_contains(tbl, obj)
	return tbl[obj] ~= nil
end

function enumerate_array(array, predicate)
	for i, v in ipairs(array) do
		predicate(i, v)
	end
end

function enumerate_table(tbl, predicate)
	for k, v in pairs(tbl) do
		predicate(k, v)
	end
end

function filter_array(array, predicate)
	local result = {}

	for i, v in ipairs(array) do
		if predicate(k, v) then
			result[#result+1] = v
		end
	end

	return result
end

function filter_table(tbl, predicate)
	local result = {}

	for k, v in pairs(tbl) do
		if predicate(k, v) then
			result[k] = v
		end
	end

	return result
end

function to_array(tbl)
	local result = {}

	for _, obj in pairs(tbl) do
		result[#result+1] = obj
	end

	return result
end

function to_sorted_array(tbl, predicate)
	local list = to_array(tbl)
	table.sort(list, predicate)
	return list
end

function upper_first(str)
	return str:gsub("^.", string.upper)
end
