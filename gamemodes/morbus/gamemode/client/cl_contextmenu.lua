-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team
--It didn't fit in any other file imp


function GM:OnContextMenuOpen()
    if GetRoundState() == ROUND_WAIT then return end
    if (GetRoundState() ~= ROUND_ACTIVE) and (RoundHistory["First"] ~= nil) then
        OPEN_RHISTORY()
        return
    end
    value = true
    if LocalPlayer():IsBrood() then
        if pUpgradesMenu and pUpgradesMenu:IsValid() then
            pUpgradesMenu:Remove()
            if pDescriptionBox then
                pDescriptionBox:Remove()
            end
            value = false
        end
        if value then
            CreateUpgradesMenu()
        end
    end

    -- Swarm Alien Shop

    value = true
    if LocalPlayer():IsSwarm() then
        if pSwarmShop and pSwarmShop:IsValid() then
            pSwarmShop:Remove()
            value = false
        end
        if pDescriptionBox then
            pDescriptionBox:Remove()
        end
        if value then
            CreateSwarmShop()
        end
    end
end
