
local function appendAssets(gameRoot, modPath, prefix)
	local modRoot = (modApi:getCurrentMod().resourcePath..modPath):gsub("^.*[^\\/]$","%1/")
	local files = mod_loader:enumerateFilesIn(modRoot)
	prefix = prefix or ""
	for _, file in ipairs(files) do
		if file:find(".png$") then
			modApi:appendAsset(gameRoot..prefix..file, modRoot..file)
		end
	end
end

function modApi:appendPlayerUnitAssets(path, prefix)
	appendAssets("img/units/player/", path, prefix)
end

function modApi:appendEnemyUnitAssets(path, prefix)
	appendAssets("img/units/aliens/", path, prefix)
end

function modApi:appendMissionUnitAssets(path, prefix)
	appendAssets("img/units/mission/", path, prefix)
end

function modApi:appendBotUnitAssets(path, prefix)
	appendAssets("img/units/snowbots/", path, prefix)
end

function modApi:appendCombatAssets(path, prefix)
	appendAssets("img/combat/", path, prefix)
end

function modApi:appendCombatIconAssets(path, prefix)
	appendAssets("img/combat/icons/", path, prefix)
end

function modApi:appendEffectAssets(path, prefix)
	appendAssets("img/effects/", path, prefix)
end

function modApi:appendWeaponAssets(path, prefix)
	appendAssets("img/weapons/", path, prefix)
end

function modApi:appendPassiveWeaponAssets(path, prefix)
	appendAssets("img/weapons/passives/", path, prefix)
end

modApi.appendMechAssets = modApi.appendPlayerUnitAssets
modApi.appendVekAssets = modApi.appendEnemyUnitAssets
modApi.appendBotAssets = modApi.appendBotUnitAssets
