-- Generated from template

if admiral_wars == nil then
	admiral_wars = class({})
end

function Precache( context )
	PrecacheUnitByNameSync("npc_dota_hero_kunkka", context)
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = admiral_wars()
	GameRules.AddonTemplate:InitGameMode()
end

function admiral_wars:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:SetHeroSelectionTime( 0.0 )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(CAddonTemplateGameMode, 'OnPlayerConnectFull'), self)
	self.direKills = 0
	self.radiantKills = 0
	self.kills_to_win = 30 --set this to the number of kills you want
	
	ListenToGameEvent("entity_killed", Dynamic_Wrap(admiral_wars, "OnEntityKilled"), self)
end
function admiral_wars:OnEntityKilled(keys)
    local killedEntity = EntIndexToHScript(keys.entindex_killed)
 
    if killedEntity:IsRealHero() then
        local playerTeam = killedEntity:GetTeam()
        if playerTeam == 2 then
            self.direKills = self.direKills + 1
            if self.direKills >= self.kills_to_win then
                GameRules:SetSafeToLeave( true )
                GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
            end
        elseif playerTeam == 3 then
            self.radiantKills = self.radiantKills + 1
            if self.radiantKills >= self.kills_to_win then
                GameRules:SetSafeToLeave( true )
                GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
            end
        end
    end
end

-- Evaluate the state of the game
function admiral_wars:OnThink()
	-- Reconnect heroes
    for _,hero in pairs( Entities:FindAllByClassname( "npc_dota_hero_kunkka")) do
        if hero:GetPlayerOwnerID() == -1 then
            local id = hero:GetPlayerOwner():GetPlayerID()
            if id ~= -1 then
                print("Reconnecting hero for player " .. id)
                hero:SetControllableByPlayer(id, true)
                hero:SetPlayerID(id)
            end
        end
    end
	--
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function CAddonTemplateGameMode:OnPlayerConnectFull(keys)
    local player = PlayerInstanceFromIndex(keys.index + 1)
    print("Creating hero.")
    local hero = CreateHeroForPlayer('npc_dota_hero_lina', player)
end