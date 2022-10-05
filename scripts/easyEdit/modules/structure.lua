
local function getCurrentModResourcePath()
	local mod = modApi:getCurrentMod()
	return mod.resourcePath
end

local function newStructure(structure)
	local id = structure.Id
	local name = structure.Name
	local path = structure.Path
	local image = structure.Image
	local imageOffset = structure.ImageOffset
	local reward = structure.Reward

	Assert.Equals('string', type(name), "Name")
	Assert.Equals('string', type(path), "Path")
	Assert.Equals('string', type(image), "Image")
	Assert.TypePoint(imageOffset, "ImageOffset")
	Assert.Equals('number', type(reward), "Reward")
	Assert.Range(0, 2, reward, "Reward")

	if modApi.currentMod then
		path = getCurrentModResourcePath()..path
	end

	local image_on = image.."_on.png"
	local image_broken = image.."_broken.png"
	local assetroot = "img/combat/structures/"
	local filepath_on = path..image_on
	local filepath_broken = path..image_broken
	local assetpath_on = assetroot..image_on
	local assetpath_broken= assetroot..image_broken
	local textId = id.."_Name"

	Assert.FileExists(filepath_on)
	Assert.FileExists(filepath_broken)
	Assert.Equals(false, modApi:assetExists(assetpath_on), "Asset '"..assetpath_on.."' already exists")
	Assert.Equals(false, modApi:assetExists(assetpath_broken), "Asset '"..assetpath_broken.."' already exists")
	Assert.Equals('nil', type(Mission_Texts[textId]), "Mission Text '"..textId.."' already exists")

	modApi:appendAsset(assetpath_on, filepath_on)
	modApi:appendAsset(assetpath_broken, filepath_broken)
	Location[assetpath_on:sub(5,-1)] = imageOffset
	Location[assetpath_broken:sub(5,-1)] = imageOffset
	Mission_Texts[textId] = name

	return {
		Name = name,
		Image = image,
		Reward = reward
	}
end

function CreateStructure(structure)
	Assert.Equals('table', type(structure), "Argument #1")
	Assert.Equals('string', type(structure.Id), "Id")
	Assert.Equals('nil', type(_G[structure.Id]), "Entry with id '"..structure.Id.."' already exists")

	_G[structure.Id] = newStructure(structure)
end
