-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team


local function CreateDeathEffect(ent)
    local pos = ent:GetPos() + Vector(0, 0, 20)

    local jit = 35.0

    local jitter = Vector(math.Rand(-jit, jit), math.Rand(-jit, jit), 0)
    util.PaintDown(pos + jitter, "Blood", ent)
end

function GM:PlayerDeathThink(ply)
    if GetRoundState() == ROUND_WAIT and ply:IsGame() then
        if (CurTime() >= ply.NextSpawnTime) then
            ply:SetRole(ROLE_HUMAN)
            ply:SpectateEntity(nil)
            ply:UnSpectate()
            ply:Spawn()
        end

        return true
    end

    if ply:IsBrood() and ply:IsGame() then
        if (CurTime() >= ply.NextSpawnTime) then
            ply:Spawn()
        end

        return true
    end

    if ply:IsSwarm() and ply:IsGame() then
        if (CurTime() >= ply.NextSpawnTime) then
            ply:Spawn()
            ply:UnSpectate()
        end

        return true
    end

    -- when spectating a ragdoll after death
    if ply:GetMoveType() < MOVETYPE_NOCLIP and ply:GetMoveType() > 0 or ply:GetMoveType() == MOVETYPE_LADDER then
        ply:Spectate(OBS_MODE_ROAMING)
    end

    -- when speccing a player
    if ply:GetObserverMode() ~= OBS_MODE_ROAMING then
        local tgt = ply:GetObserverTarget()
        if IsValid(tgt) and tgt:IsPlayer() then
            if (not tgt:IsGame()) or (not tgt:Alive()) then
                -- stop speccing as soon as target dies
                ply:Spectate(OBS_MODE_ROAMING)
                ply:SpectateEntity(nil)
            elseif GetRoundState() == ROUND_ACTIVE then
                -- Sync position to target. Uglier than parenting, but unlike
                -- parenting this is less sensitive to breakage: if we are
                -- no longer spectating, we will never sync to their position.
                ply:SetPos(tgt:GetPos())
            end
        end
    end
end

function GM:PlayerDeathSound() return true end -- When you return true it overrides, yes i know

function GM:DoPlayerDeath(ply, attacker, dmginfo)
    LIGHT.TurnOff(ply)
    ply:ResetViewRoll()

    ply.Killer = ents.Create("info_player_start")
    if IsValid(ply.Killer) then
        ply.Killer:SetPos(ply:GetPos())
        ply.Killer:Spawn()
    end

    for k, wep in pairs(ply:GetWeapons()) do
        WEPS.DropNotifiedWeapon(ply, wep, true)   -- with ammo in them
        wep:DampenDrop()
    end

    ply:LightReset()
    ply:DeathSound()

    if ply:IsBrood() then
        ply:SetModel(Models.Brood)
    end

    if (not ply:IsSpec()) then
        local rag = CreateCorpse(ply, attacker, dmginfo)
        ply.ragdoll = rag
        CreateDeathEffect(ply)
    end

    if ply:GetDeathFX() == 1 then
        ParticleEffect("death_blood", ply:GetPos(), Angle(0, 0, 0), nil)
    elseif ply:GetDeathFX() == 2 then
        ParticleEffect("cryo_explosion", ply:GetPos(), Angle(0, 0, 0), nil)
    elseif ply:GetDeathFX() == 3 then
        ParticleEffect("death_fire", ply:GetPos(), Angle(0, 0, 0), nil)
    elseif ply:GetDeathFX() == 4 then
        ParticleEffect("death_venom", ply:GetPos(), Angle(0, 0, 0), nil)
    elseif ply:GetDeathFX() == 5 then
        ParticleEffect("death_vortex", ply:GetPos(), Angle(0, 0, 0), nil)
    end
end

function GM:PlayerDeath(victim, weapon, killer)
    if killer:GetClass() == "env_explosion" then
        killer = killer:GetOwner()
    end

    if (victim:IsSpec()) then
        return
    end

    if killer:IsPlayer() and killer ~= victim and victim:IsAlien() and not killer:GetNWBool("alienform", false) then
        killer:KilledAlien()
    end

    if GetRoundState() == ROUND_ACTIVE then
        if victim.FreeKill < CurTime() and killer:IsPlayer() then
            if killer:GetHuman() and victim:GetHuman() then
                killer.FreeKill = CurTime() + 5
            end

            SANITY.Killed(killer, victim, dmginfo)
        end
    end

    -- Dont bother with this shit if we arent playing
    if (GetRoundState() ~= ROUND_ACTIVE) then
        victim.NextSpawnTime = CurTime() + 5
        return
    end

    -- Infection timer
    if not victim:IsAlien() and victim.BroodInfect then
        if victim.BroodInfect > CurTime() and victim.BroodHit then
            LogInfect(victim.BroodHit, victim, " Brood ")
            Death_Brood_Infect(victim, weapon, victim.BroodHit)
            return
        end
    end

    if not killer:IsPlayer() then
        -- The played died from UNKNOWN causes (Falling, crushed by map)
        LogDeath(victim, " Unknown ")
        Death_Unknown(victim, weapon, killer)
    elseif killer:GetActiveWeapon() == NULL or weapon == victim then
        -- The player killed themselves
        LogDeath(victim, " Suicide ")
        Death_Suicide(victim, weapon, killer)
    elseif killer:GetActiveWeapon():GetClass() == "weapon_mor_swarm" and not victim:IsAlien() then
        -- The player is infected by a Swarm Alien
        LogInfect(killer, victim, " Swarm ")
        Round_Swarm_Infects = Round_Swarm_Infects + 1
        Death_Swarm_infect(victim, weapon, killer)
    elseif victim:IsBrood() then
        -- The player was a Brood Alien & died
        LogKill(victim, killer, " Brood Killed ")
        Round_Brood_Kills = Round_Brood_Kills + 1
        Death_Brood(victim, weapon, killer)
    elseif victim:IsSwarm() then
        -- The player was a Swarm Alien & died
        LogKill(victim, killer, " Swarm Killed ")
        Round_Swarm_Kills = Round_Swarm_Kills + 1
        Death_Swarm(victim, weapon, killer)
    elseif killer:GetActiveWeapon():GetClass() == "weapon_mor_brood" and not victim:IsAlien() then
        -- The player was infected by a Brood Alien
        LogInfect(killer, victim, " Brood ")
        Round_Brood_Infects = Round_Brood_Infects + 1
        Death_Brood_Infect(victim, weapon, killer)
    else -- If the player did not suide, was not killed with brood/spawn weapon, if the player was not a brood or spawn
        if (victim:IsAlien() and killer:IsAlien()) or (not victim:IsAlien() and not killer:IsAlien()) then
            -- The player was killed by their team member
            LogRDM(killer, victim, " RDM ")
            Round_RDMs = Round_RDMs + 1
        else
            -- The player is an alien and shot by a human, or vice versa
            LogKill(victim, killer, " KILL ")
        end

        -- Normal death
        Death_Normal(victim, weapon, killer)
    end
end

function Death_Normal(ply, weapon, killer)
    if ply:IsSwarm() then
        Death_Swarm(ply, weapon, killer)
        return
    end

    -- Brood Kills another Brood
    if killer:IsBrood() and ply:IsBrood() and killer ~= ply then
        killer:SetRDMScorePotential(killer:GetRDMScorePotential() + 1)
        killer:AddFrags(-2)

        -- Punish the player more if they have more RDMs this game.
        if killer:GetRDMScore() > 1 then
            killer:SetLiveSanity(killer:GetLiveSanity() - 200)
        end

        -- Three strikes you're out, at least three strikes in a row.
        if killer:GetRDMScorePotential() > 2 then
            killer:SetLiveSanity(killer:GetLiveSanity() - 350)
        end

        PlayerMsg(killer, "RDM is against the rules! Press F2 for the rules, to avoid penalties.", false)
    end

    -- Human Kills another Human
    if not killer:IsAlien() and not ply:IsAlien() and killer ~= ply then
        killer:SetRDMScorePotential(killer:GetRDMScorePotential() + 1)
        killer:AddFrags(-1)

        -- Punish the player more if they have more RDMs this game.
        if killer:GetRDMScore() > 1 then
            killer:SetLiveSanity(killer:GetLiveSanity() - 150)
        end

        -- Three strikes you're out, at least three strikes in a row.
        if killer:GetRDMScorePotential() > 2 then
            killer:SetLiveSanity(killer:GetLiveSanity() - 350)
        end

        PlayerMsg(killer, "RDM is against the rules! Press F2 for the rules, to avoid penalties.", false)
    end

    -- Human Kills a Brood
    if not killer:IsAlien() and ply:IsBrood() then
        killer:SetAlienKillsPotential(killer:GetAlienKillsPotential() + 1)
        killer:AddFrags(1)
    end

    -- Brood Kills a Human
    if killer:IsBrood() and not ply:IsAlien() then
        killer:SetLiveSanity(killer:GetLiveSanity() - 250)
        PlayerMsg(killer, "Killing humans with guns will reduce sanity!", false)
    end

    NewAlien(ply, ROLE_SWARM)
end

function Death_Unknown(ply, wpn, klr)
    if ply:IsBrood() then
        Death_Swarm(ply, wpn, klr)
        hook.Call("MorbusBroodDied", GAMEMODE)
        return
    end

    if ply:IsSwarm() then
        Death_Swarm(ply, weapon, killer)
        return
    end

    NewAlien(ply, ROLE_SWARM)
end

function Death_Suicide(ply, wpn, klr)
    if ply:IsBrood() then
        Death_Normal(ply, wpn, klr)
        hook.Call("MorbusBroodDied", GAMEMODE)
        return
    end

    Death_Normal(ply, wpn, klr)
end

function Death_Brood(ply, weapon, killer)
    Death_Normal(ply, weapon, killer)

    hook.Call("MorbusBroodDied", GAMEMODE)

    if ply ~= killer then
        if not RoundHistory["Kill"][killer] then
            RoundHistory["Kill"][killer] = 0
        end

        RoundHistory["Kill"][killer] = RoundHistory["Kill"][killer] + 1
    end
end

function Death_Swarm(ply, weapon, killer)
    if (Swarm_Respawns > 0) then                              -- If we have respawns
        Swarm_Respawns = Swarm_Respawns - 1                   -- Take one away
        SetGlobalInt("morbus_swarm_spawns", Swarm_Respawns)   -- Update the global
        ply.NextSpawnTime = CurTime() + 8                     -- Respawn us in 8 seconds
    else
        ply:MakeSpec()                                        -- No respawns, become a spectator
    end

    if not killer:IsAlien() then
        killer:SetAlienKillsPotential(killer:GetAlienKillsPotential() + 1)
    end

    if ply ~= killer then
        if not RoundHistory["Kill"][killer] then
            RoundHistory["Kill"][killer] = 0
        end

        RoundHistory["Kill"][killer] = RoundHistory["Kill"][killer] + 1
    end
end

function Death_Swarm_Infect(ply, weapon, killer)
    if not RoundHistory["Infect"][killer] then
        RoundHistory["Infect"][killer] = 0
    end

    RoundHistory["Infect"][killer] = RoundHistory["Infect"][killer] + 1

    killer:SetInfectionsPotential(killer:GetInfectionsPotential() + 1)
    if ply:IsCyborg() and killer:IsBrood() then
        killer.Evo_Points = killer.Evo_Points + 1
        AlienMsg(killer, "You have gained " .. (1) .. " upgrade points for killing the Cyborg!")
        killer:SendEvoPoints()
        killer:SendUpgrades()
    end

    BroodInfected(ply)

    killer:AddFrags(1)

    ply.NextSpawnTime = CurTime() + 4
end

function Death_Brood_Infect(ply, weapon, killer)
    Death_Swarm_Infect(ply, weapon, killer)
end
