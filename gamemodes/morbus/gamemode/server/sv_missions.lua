-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team
--[[
Mission stuff
--]]

-- work on this
-- TODO
function CheckMission(humans)
    if GetRoundState() ~= ROUND_ACTIVE then return end

    for k, v in pairs(humans) do
        if v.Mission_Doing then
            if v.Mission_Complete <= CurTime() then -- If completed mission
                v.Mission_Doing = false
                v.Mission_Complete = 0
                v.Mission_End = 0
                v.Mission_Next = CurTime() +
                math.random(GetConVar("morbus_mission_next_time_min"):GetInt(),
                    GetConVar("morbus_mission_next_time_max"):GetInt())
                v.Mission = 0
                v:Freeze(false)
                v:SetHealth(math.Clamp(v:Health() + 25, 0, 100))

                ResetMission(v)

                if v.Gender == GENDER_FEMALE then
                    v:EmitSound(table.Random(Response.Female.Yes), 100, 100)
                else
                    v:EmitSound(table.Random(Response.Male.Yes), 100, 100)
                end
            end
        elseif (v.Mission == 0) and (v.Mission_Next <= CurTime()) then
            --safety
            v.Mission_Complete = 0
            v.Mission_Next = 0
            v.Mission_Doing = false
            v.Mission = math.random(1, 4)
            v.Mission_End = CurTime() +
            math.random(GetConVar("morbus_mission_time_min"):GetInt(), GetConVar("morbus_mission_time_max"):GetInt())
            v:SendMission()
            if v.Gender == GENDER_FEMALE then
                v:EmitSound(table.Random(Tuants.Female), 100, 100)
            else
                v:EmitSound(table.Random(Tuants.Male), 100, 100)
            end
        end
    end
end

function DoMission(ply, cmd, args)
    if not IsValid(ply) then return end

    if not ply:Alive() then return end

    if ply.Mission == MISSION_NONE or ply.Mission == MISSION_KILL or ply.Mission == MISSION_PURGE then return end

    if ply.Mission_Doing == true then return end

    if ply.Touching ~= MISSION_NONE and ply.Touching == ply.Mission then
        ply.Mission_Doing = true
        ply.Mission_Complete = CurTime() + TTC_MISSION
        if ply.Mission ~= 4 then
            ply:EmitSound(Sounds.Mission[ply.Mission], 75, 100)
        else
            local r = math.random(1, 10)
            if r <= 3 then
                ply:EmitSound(Sounds.Mission[ply.Mission + 1], 125, 100)
            else
                ply:EmitSound(Sounds.Mission[ply.Mission], 75, 100)
            end
        end

        ply:SendMissionComplete()
        ply:Freeze(true)
    end
end

concommand.Add("morbus_use", DoMission)
