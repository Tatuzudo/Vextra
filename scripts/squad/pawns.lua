local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local names = {
	"StinkbugMech",
	"DragonflyMech",
	"FlyMech",
}
for _, ptname in pairs(names) do
	modApi:appendAsset("img/portraits/pilots/Pilot_DNT_"..ptname..".png",resourcePath.."img/portraits/pilots/Pilot_DNT_"..ptname..".png")
	CreatePilot{
		Id = "Pilot_DNT_"..ptname,
		Personality = "Vek",
		Sex = SEX_VEK,
		Rarity = 0,
		Skill = "Survive_Death",
		Blacklist = {"Invulnerable", "Popular"},
	}
end

DNT_DragonflyMech = Pawn:new
	{
		Name = "Techno-Dragonfly",
		Health = 2,
		MoveSpeed = 3,
		Flying = true,
    ImageOffset = 8,
    Class = "TechnoVek",
		Image = "DNT_dragonfly_mech", --change
		SkillList = {"DNT_SS_SparkHurl"},
		SoundLocation = "/enemy/moth_1/",
		DefaultTeam = TEAM_PLAYER,
		ImpactMaterial = IMPACT_INSECT,
    Massive = true,
	}
AddPawn("DNT_DragonflyMech")

DNT_FlyMech = Pawn:new{
	Name = "Techno-Fly",
	Health = 3,
	StartingHealth = 1,
	MoveSpeed = 4,
	Image = "DNT_fly_mech",
	Flying = true,
  ImageOffset = 8,
  Class = "TechnoVek",
	SkillList = { "DNT_SS_SappingProboscis" },
	SoundLocation = "/enemy/hornet_1/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
  Massive = true,
}
AddPawn("DNT_FlyMech")

DNT_StinkbugMech = Pawn:new
	{
		Name = "Techno-Stinkbug",
		Description = "Description",
		Health = 2,
		MoveSpeed = 4,
    ImageOffset = 8,
    Class = "TechnoVek",
		Image = "DNT_stinkbug_mech", --Image = "DNT_stinkbug" --lowercase
		SkillList = {"DNT_SS_AcridSpray"},
		SoundLocation = "/enemy/scarab_1/",
		DefaultTeam = TEAM_PLAYER,
		ImpactMaterial = IMPACT_INSECT,
    Massive = true,
	}
AddPawn("DNT_StinkbugMech")
