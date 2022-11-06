# ITB-Easy-Edit
 This is an Into the Breach mod loader extension by Lemonymous @ https://github.com/Lemonymous. It can either be used as a stand-alone mod, or integrated into mods using its features.
 
It intends to make it much easier for mod creators to do many things that were previously very difficult: The creation of new islands, tilesets, corporations, enemylists, etc. See the documentation for a full function list.

Easy Edit is now included in modloader 2.8.0, but can also be installed separately, although you should be on the newest modloader unless there's some other reason you are not. 

#Features (For Players [And Modders])
 Clicking Mod Content is how you access all of Easy Edits Features, where the options are located near the bottom. All options have a default button at the bottom that will reset everything in that option menu to default. It does not ask if you want to, so only click it if you're sure you want it or things are getting messed up and it needs a reset. 

Configure EasyEdit: Enable Easy Edit here as well as some other debug options. 

Enemy Lists Editor: Here, you can edit the enemy lists, which is the list of enemies that the game will pull from when creating islands. The base game lists will show up here, and any mods that add lists will also have their own. You can reset these lists to default by hitting the red button on the left. You can also create your own list at the bottom, which can then have Vek added to it from the scroll bar on the right, that contains every Vek added to the game. The Final List is what is used for the finale island, and editing it will change the Vek spawns there. 
Core: The basic 3 Vek that spawn on each island Ex: Firefly, Scorpion
Unique: The Vek that get added on islands 2-4 Ex: Beetle, Crab
Bots: The robots that will be used on Pinnacle
Leaders: The Vek that show up in the final island slot, usually Psions, not to be confused by Vek Bosses

Boss Lists Editor: Works the same way as enemy lists, but with the Boss/Leader Vek instead. Finale I is the possible bosses that can spawn in phase one of the finale and Finale II is the possible bossses that can spawn in phase two of the finale.
Note: The titled lists do not determine what that island spawns like finale lists. These can be changed later in the Island Editor

Mission Lists Editor: Works the same way as enemy or boss lists, but with missions instead. 
High Threat: The missions selected that are considered a high threat
Low Threat: THe missions selected that are considered a low threat

Structure Lists Editor: Works the same way with the other lists but with structure spawns instead
Core: Determines which structures will spawn for a core reward
Rep: Determines which structures will spawn for a reputation reward
Power: Determines which structures will spawn for a grid/power reward

Island Editor: Here's where you can actually determine which islands use which lists. Clicking on an island in the left scroll bar will open up all its info which can be changed (info below). You can also create your own island by clicking New island, or reset an island to its default by clicking the red button in the bottom left when hovering an island in the left scroll bar. 
Island: Determines the map and look of an island on mission select screens
Corporation: Changes the islands corporation
CEO: Changes the islands CEO
Tileset: Changes the islands tileset in actual missions
Enemy List: Determines which enemy list that island will pull from when deciding which enemies that island will have
Boss List: Determines which boss list that island will pull from when deciding which boss that island will have
Mission List: Determines which mission list that island will pull from when deciding which missions that island will have
Structures List: Determines which structures list that island will pull from when deciding which structures that island will have

World Editor: Determines which 4 islands the game will have on the island select screen. Drag and drop islands from the right scroll bar to change them. A restart is required for the art to change. 

# Documentation (For Modders)
 See the [wiki](../../wiki) for documentation.

# Licence
 The code uses GNU GENERAL PUBLIC LICENSE, which can be read in the file LICENCE provided.

#Credits
 Made By: Lemonymous
 README By: NamesAreHard (Cause I'm not doing all this just to not get credit XD)