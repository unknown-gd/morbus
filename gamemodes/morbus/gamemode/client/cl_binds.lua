-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team
--[[
MORBUS CLIENT KEY AND BIND HANDLING
--]]

local function SendWeaponDrop()
    RunConsoleCommand("morbus_dropweapon")
end

function GM:OnSpawnMenuOpen()
    SendWeaponDrop()
end

function GM:PlayerBindPress(ply, bind, pressed)
    if not IsValid(ply) then return end

    if bind == "invnext" and pressed then
        WSWITCH:SelectNext()
        return true
    elseif bind == "invprev" and pressed then
        WSWITCH:SelectPrev()
        return true
    elseif bind == "+attack" then
        if WSWITCH.Show then
            if not pressed then
                WSWITCH:ConfirmSelection()
            end

            return true
        end
    elseif bind == "+zoom" then
        -- set voice type here just in case shift is no longer down when the
        -- PlayerStartVoice hook runs, which might be the case when switching to
        -- steam overlay
        --MsgN("HOOK")
        --ply.alien_voice = false
        --RunConsoleCommand("morbus_alien_voice", "0")
        --return true
        --    elseif bind == "lastinv" then
    elseif bind == "+use" then
        CheckBody()
        RunConsoleCommand("morbus_use")
    elseif string.sub(bind, 1, 4) == "slot" and pressed then
        local idx = tonumber(string.sub(bind, 5, -1)) or 1
        WSWITCH:SelectSlot(idx)
        return true
    elseif bind == "noclip" and pressed then
        if not GetConVar("sv_cheats"):GetBool() then
            RunConsoleCommand("morbus_equipswitch")
            return true
        end
    elseif (bind == "gmod_undo" or bind == "undo") and pressed then
        RunConsoleCommand("morbus_dropammo")
        return true
    end
end

function GM:PlayerButtonUp(ply, btn)
    if not IsFirstTimePredicted() then return end

    -- Would be nice to clean up this whole "all key handling in massive
    -- functions" thing. oh well

    if btn == KEY_C and not input.IsButtonDown(KEY_C) then
        if ply:IsSwarm() then
            if pSwarmShop and pSwarmShop:IsValid() then
                pSwarmShop:Remove()
            end

            if pDescriptionBox then
                pDescriptionBox:Remove()
            end
        end

        if ply:IsBrood() then
            if pUpgradesMenu and pUpgradesMenu:IsValid() then
                pUpgradesMenu:Remove()
                if pDescriptionBox and pDescriptionBox:IsValid() then
                    pDescriptionBox:Remove()
                end
            end
        end
    end
end

function GM:KeyPress(ply, key)
    if not IsFirstTimePredicted() then return end

    if not IsValid(ply) or ply ~= LocalPlayer() then return end

    if key == IN_ZOOM and ply:IsActiveAlien() then
        timer.Simple(0.05, function() permissions.EnableVoiceChat(true) end)
    end
end

function GM:KeyRelease(ply, key)
    if not IsFirstTimePredicted() then return end

    if not IsValid(ply) or ply ~= LocalPlayer() then return end

    if key == IN_ZOOM and ply:IsActiveAlien() then
        timer.Simple(0.05, function() permissions.EnableVoiceChat(false) end)
    end
end
