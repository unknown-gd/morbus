-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team
--[[
BASE HUD_DEBUG STUFF
--]]
HUD_DEBUG = {}
for i = 1, 17 do
    HUD_DEBUG[i] = true
end

function GM:HUDPaint()
    local client = LocalPlayer()

    if not (client:Team() == TEAM_SPEC) then
        if HUD_DEBUG[1] then
            if client:GetNWBool("alienform", false) then
                DrawDistortion()
            end

            --DrawInsanity()
        end

        if HUD_DEBUG[2] then
            --Main HUD
        end

        if HUD_DEBUG[3] then
            GAMEMODE:HUDDrawTargetID()
        end

        if HUD_DEBUG[4] then
            MSYS:Draw(client)
        end

        if HUD_DEBUG[5] then
            WSWITCH:Draw(client)
        end

        if HUD_DEBUG[6] then
            --Gun Display
        end

        if HUD_DEBUG[7] then
            GAMEMODE:HUDDrawPickupHistory()
        end

        if HUD_DEBUG[8] then
            if Morbus.Mission_Doing == true then
                MissionAlert(client)
            else
                MissionLocation(client)
            end
        end

        if HUD_DEBUG[9] then
            RoundAlert(client)
        end
    else
        if HUD_DEBUG[9] then
            RoundAlert(client)
        end

        --Spectator HUD
        if HUD_DEBUG[12] then
            GAMEMODE:HUDDrawTargetID()
            local rawend = GetGlobalFloat("morbus_round_end", 0)
            local roundend = string.FormattedTime(rawend - CurTime(), "%02i:%02i")
            if not rawend or (rawend and rawend <= CurTime()) then roundend = "00:00" end

            draw.SimpleText("You are a spectator. You will respawn when another Brood Alien is created.", "TabLarge",
                ScrW() / 2, ScrH() - 100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2,
                Color(80, 80, 80, 255))
            draw.SimpleText("You can make yourself a spectator permanently by typing /spec in chat.", "TabLarge",
                ScrW() / 2, ScrH() - 85, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2,
                Color(80, 80, 80, 255))
            draw.SimpleText(
            "SWARM LIVES: " .. tostring(GetGlobalInt("morbus_swarm_spawns", 0)) .. "   ROUND TIME: " .. roundend,
                "TabLarge", ScrW() / 2, ScrH() - 70, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2,
                Color(80, 80, 80, 255))
        end
    end

    if HUD_DEBUG[14] then
        VoiceIndicators(client)
    end
end

function MissionAlert(ply)
    if Morbus.Mission_Doing then
        draw.SimpleTextOutlined(
        "Completing mission! Please wait " .. math.ceil((Morbus.Mission_Complete - CurTime())) .. " seconds", "DSLarge",
            ScrW() / 2, ScrH() / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2,
            Color(0, 0, 0, 255))
    end
end

function RoundAlert(ply)
    if GetRoundState() == ROUND_POST then
        if GetGlobalInt("morbus_winner", WIN_HUMAN) == WIN_HUMAN then
            draw.SimpleTextOutlined("Humans win!", "DSLarge", ScrW() / 2, ScrH() / 2, Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 255))
        elseif GetGlobalInt("morbus_winner", WIN_HUMAN) == WIN_ALIEN then
            draw.SimpleTextOutlined("Aliens win!", "DSLarge", ScrW() / 2, ScrH() / 2, Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 255))
        else
            draw.SimpleTextOutlined("Humans win!", "DSLarge", ScrW() / 2, ScrH() / 2, Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 255))
        end
    end
end

--[[
HUD_DEBUG EFFECT
--]]
local hud = { "CHudHealth", "CHudBattery", "CHudAmmo", "CHudCrosshair", "CHudSecondaryAmmo", "CHudVoiceStatus",
    "CHudVoiceStatusSelf" }
function GM:HUDShouldDraw(name)
    for k, v in pairs(hud) do
        if name == v then return false end
    end

    return true
end
