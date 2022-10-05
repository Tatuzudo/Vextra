
local function isdir(path)
	return modApi:directoryExists(path)
end

local function isfile(path)
	return modApi:fileExists(path)
end

local function pruneExtension(path)
	return string.gsub(path, "[.][^.]*$", "")
end


return {
	listdirs = os.listdirs,
	listfiles = os.listfiles,
	listobjects = os.listobjects,
	pruneExtension = pruneExtension,
	isdir = isdir,
	isfile = isfile,
}
