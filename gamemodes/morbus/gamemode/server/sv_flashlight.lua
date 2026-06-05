-- Morbus - morbus.remscar.com
-- Developed by Remscar and the Morbus dev team
--[[
JEsus a whole file!
--]]


function PlayerSwitchFlashlight(ply, on)
    if not IsValid(ply) then return false end

    if ply:Team() == TEAM_SPEC or ply:IsSwarm() then
        ply.NightVision = not ply.NightVision
        LIGHT.SendNightVision(ply)
        return false
    end

    if not ply:IsSwarm() and ply:IsGame() and ply:Alive() and not ply:GetNWBool("alienform", false) and not GetGlobalBool("mutator_nightmare", false) then
        flashlight = ply:GetNWEntity('Flashlight', NULL)
        if flashlight == NULL and not ply.Light and (ply.Battery > 1) then
            ply:EmitSound("items/flashlight1.wav", 50, 110)
            LIGHT.TurnOn(ply)
        else
            LIGHT.TurnOff(ply)
            ply:EmitSound("items/flashlight1.wav", 50, 90)
        end
    else
        if not on then
            LIGHT.TurnOff(ply)
            ply:SetNWBool("Flashlight_On", false)
            ply:RemoveEffects(EF_DIMLIGHT)
        end
    end

    return false
end

hook.Add('PlayerSwitchFlashlight', 'PlayerSwitchFlashlight', PlayerSwitchFlashlight)

function Flashlight_Update(ply)
    flashlight = ply:GetNWEntity('Flashlight', NULL)
    if not ply:Alive() and flashlight then
        LIGHT.TurnOff(ply)
    end

    ply:AllowFlashlight(false)
    if IsValid(flashlight) then
        if SERVER then
            flashlight:SetPos(ply:EyePos() + ply:EyeAngles():Forward() * 15)
            flashlight:SetAngles(ply:EyeAngles())
        end
    end
end

hook.Add('PlayerPostThink', 'Flashlight_Update', Flashlight_Update)

function LIGHT.TurnOn(ply)
    ply.Light = true
    LIGHT.SendStatus(ply)
    LIGHT.SendBattery(ply)
    ply.FakeLight = true
    ply.Battery = ply.Battery - 1

    if SERVER then
        local col = Color(255, 255, 200)
        local bright = 255
        local size = 60
        local len = 750
        flashlight = ents.Create("env_projectedtexture")
        flashlight:SetPos(ply:EyePos() + ply:EyeAngles():Forward() * 34)
        flashlight:SetAngles(ply:EyeAngles())
        flashlight:SetKeyValue("enableshadows", 1)
        flashlight:SetKeyValue("nearz", 20)
        flashlight:SetKeyValue("farz", len)
        flashlight:SetKeyValue("lightfov", 75)
        flashlight:SetKeyValue("lightcolor", Format("%i %i %i 255", col.r, col.g, col.b))
        flashlight:Spawn()
        flashlight:Input("SpotlightTexture", NULL, NULL, "effects/Flashlight001.vmt")
        ply:SetNWEntity('Flashlight', flashlight)
    end

    ply:SetNWBool("Flashlight_On", true)
end

function LIGHT.TurnOff(ply)
    ply.Light = false
    --ply:RemoveEffects(EF_DIMLIGHT)
    LIGHT.SendStatus(ply)
    LIGHT.SendBattery(ply)
    ply.FakeLight = false

    flashlight = ply:GetNWEntity('Flashlight', NULL)

    if flashlight then
        ply:SetNWEntity('Flashlight', NULL)
        SafeRemoveEntity(flashlight)
        flashlight = nil
    end

    ply:SetNWBool("Flashlight_On", false)
end

function LIGHT.FakeOff(ply)
    ply.FakeLight = false
    ply:RemoveEffects(EF_DIMLIGHT)
end

function LIGHT.FakeOn(ply)
    ply.FakeLight = true
    ply:AddEffects(EF_DIMLIGHT)
end

function LIGHT.SendStatus(ply)
    umsg.Start("SendLight", ply)
    umsg.Bool(ply.Light)
    umsg.End()
end

function LIGHT.SendBattery(ply)
    umsg.Start("SendBattery", ply)
    umsg.Long(ply.Battery)
    umsg.End()
end

function LIGHT.SendNightVision(ply)
    umsg.Start("SendNV", ply)
    umsg.Bool(ply.NightVision)
    umsg.End()
end

function LIGHT.Think(ply)   --Actually called every 1 second
    if ply.Light then
        if ply.Battery > 0 then
            if ply:IsCyborg() then
                ply.Battery = 100
            else
                ply.Battery = ply.Battery - 1
            end

            if ply.Battery <= 0 then
                ply.Battery = 0
                LIGHT.TurnOff(ply)
            end
        else
            ply.Battery = 0
            LIGHT.TurnOff(ply)
        end
    else
        if ply.Battery and ply.Battery < LIGHT_BATTERY then
            ply.Battery = LIGHT.ToTime(LIGHT.Regen(LIGHT.Precent(ply.Battery))) + ply.Battery
            if ply.Battery > LIGHT_BATTERY then
                ply.Battery = LIGHT_BATTERY
            end

            LIGHT.SendBattery(ply)
        end
    end
end
