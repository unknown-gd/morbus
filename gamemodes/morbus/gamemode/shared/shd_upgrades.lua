--[[
SO MANY UPGRADES BITCHES
--]]


UPGRADE = {}       --To be used as ENUM
UPGRADES = {}      -- Used to store upgrade data
UPGRADE_TREES = {} -- Used to store upgrade tree

-- I do it this way cause it looks nicer to me
UPGRADE_TREES[ 1 ] = "Offense"
UPGRADE_TREES[ 2 ] = "Defense"
UPGRADE_TREES[ 3 ] = "Utility"

-- The tree will be refrenced via number or enum
TREE_OFFENSE = 1
TREE_DEFENSE = 2
TREE_UTILITY = 3

-- The upgrades
-- Upgrade Icons created by: Demonkush
UPGRADE.CLAWS = 1
UPGRADE.CLAW_AMOUNT = 2
UPGRADES[ 1 ] = {
    Title = "Sharp Claws",
    Tree = TREE_OFFENSE,
    Desc = "Increases attack damage by " .. UPGRADE.CLAW_AMOUNT .. " per level",
    Icon = "vgui/morbus/brood/icon_brood_claws.png",
    MaxLevel = 3,
    Tier = 1
}


UPGRADE.CARAPACE = 2
UPGRADE.CARAPACE_AMOUNT = 20
UPGRADES[ 2 ] = {
    Title = "Hardened Carapace",
    Tree = TREE_DEFENSE,
    Desc = "Decreases damage taken by " .. UPGRADE.CARAPACE_AMOUNT .. "% per level",
    Icon = "vgui/morbus/brood/icon_brood_carapace.png",
    MaxLevel = 1,
    Tier = 2
}


UPGRADE.SPRINT = 3
UPGRADE.SPRINT_AMOUNT = 25
UPGRADES[ 3 ] = {
    Title = "Fast Twitch",
    Tree = TREE_UTILITY,
    Desc = "Increases the speed of your sprint by " .. UPGRADE.SPRINT_AMOUNT .. " per level",
    Icon = "vgui/morbus/brood/icon_brood_adrenaline.png",
    MaxLevel = 5,
    Tier = 1
}


UPGRADE.EXHAUST = 7
UPGRADE.EXHAUST_AMOUNT = 60
UPGRADES[ 7 ] = {
    Title = "Numbing Exhaustion",
    Tree = TREE_OFFENSE,
    Desc = "Decreases the time a human has to complete their need by " .. UPGRADE.EXHAUST_AMOUNT .. " seconds every attack, per level.",
    Icon = "vgui/morbus/brood/icon_brood_exhaust.png",
    MaxLevel = 1,
    Tier = 2
}


UPGRADE.SDEFENSE = 5
UPGRADE.SDEFENSE_AMOUNT = 9
UPGRADES[ 5 ] = {
    Title = "Reinforced Scales",
    Tree = TREE_DEFENSE,
    Desc = "Reduces damage from pistols and SMGs by " .. UPGRADE.SDEFENSE_AMOUNT .. "%",
    Icon = "vgui/morbus/brood/icon_brood_scales.png",
    MaxLevel = 5,
    Tier = 1
}


UPGRADE.ATKSPEED = 4
UPGRADE.ATKSPEED_AMOUNT = 11
UPGRADES[ 4 ] = {
    Title = "Relentless Barrage",
    Tree = TREE_OFFENSE,
    Desc = "Your attack speed increases by " .. UPGRADE.ATKSPEED_AMOUNT .. "% per level",
    Icon = "vgui/morbus/brood/icon_brood_relentless.png",
    MaxLevel = 4,
    Tier = 1
}


UPGRADE.REGEN = 11
UPGRADE.REGEN_AMOUNT = 1
UPGRADES[ 11 ] = {
    Title = "Regenerative Tissue",
    Tree = TREE_DEFENSE,
    Desc = "Restores " .. UPGRADE.REGEN_AMOUNT .. "*(LEVEL) health per second when in alien form",
    Icon = "vgui/morbus/brood/icon_brood_regen2.png",
    MaxLevel = 3,
    Tier = 1
}


UPGRADE.JUMP = 9
UPGRADE.JUMP_AMOUNT = 250
UPGRADES[ 9 ] = {
    Title = "Bolstering Legs",
    Tree = TREE_UTILITY,
    Desc = "Increases jump power by " .. UPGRADE.JUMP_AMOUNT .. " and prevents fall damage",
    Icon = "vgui/morbus/brood/icon_brood_jump.png",
    MaxLevel = 1,
    Tier = 1
}


UPGRADE.LIFESTEAL = 10
UPGRADE.LIFESTEAL_AMOUNT = 7
UPGRADES[ 10 ] = {
    Title = "Blood Thirst",
    Tree = TREE_OFFENSE,
    Desc = "Regenerates " .. UPGRADE.LIFESTEAL_AMOUNT .. "*(LEVEL) HP every time you attack a human",
    Icon = "vgui/morbus/brood/icon_brood_blood.png",
    MaxLevel = 2,
    Tier = 2
}


UPGRADE.HDEFENSE = 8
UPGRADE.HDEFENSE_AMOUNT = 7
UPGRADES[ 8 ] = {
    Title = "Strengthened Skeleton",
    Tree = TREE_DEFENSE,
    Desc = "Reduces damage from Rifles and Shotguns by " .. UPGRADE.HDEFENSE_AMOUNT .. "%",
    Icon = "vgui/morbus/brood/icon_brood_enforced.png",
    MaxLevel = 4,
    Tier = 1
}


UPGRADE.BREATH = 12
UPGRADES[ 12 ] = {
    Title = "Silent Breathing",
    Tree = TREE_UTILITY,
    Desc = "Mutes the sound of your breathing",
    Icon = "vgui/morbus/brood/icon_brood_mute.png",
    MaxLevel = 1,
    Tier = 1
}


UPGRADE.SMELLRANGE = 13
UPGRADE.SMELLRANGE_AMOUNT = 1100
UPGRADES[ 13 ] = {
    Title = "Olfactory Acuity",
    Tree = TREE_OFFENSE,
    Desc = "Increases the range from which you can smell humans by " .. UPGRADE.SMELLRANGE_AMOUNT .. " units per level",
    Icon = "vgui/morbus/brood/icon_brood_smell.png",
    MaxLevel = 2,
    Tier = 2
}


UPGRADE.HEALTH = 14
UPGRADE.HEALTH_AMOUNT = 25
UPGRADES[ 14 ] = {
    Title = "Enhanced Survivability",
    Tree = TREE_DEFENSE,
    Desc = "Increases maximum health by " .. UPGRADE.HEALTH_AMOUNT .. " per level",
    Icon = "vgui/morbus/brood/icon_brood_regen.png",
    MaxLevel = 4,
    Tier = 2
}


UPGRADE.INVISIBLE = 15
UPGRADES[ 15 ] = {
    Title = "Adaptive Camouflage",
    Tree = TREE_UTILITY,
    Desc = "When you stand still for 4-(LEVEL) seconds you become invisible.",
    Icon = "vgui/morbus/brood/icon_brood_question.png",
    MaxLevel = 3,
    Tier = 1
}
UPGRADE.SCREAM = 16
UPGRADES[ 16 ] = {
    Title = "Frightening Screech",
    Tree = TREE_OFFENSE,
    Desc = "When you transform into alien form, blinds and blurs nearby humans' vision.",
    Icon = "vgui/morbus/brood/icon_brood_screech.png",
    MaxLevel = 1,
    Tier = 1
}

UPGRADE.DEFENSE_T3 = 17
UPGRADES[ 17 ] = {
    Title = "Steel Plating",
    Tree = TREE_DEFENSE,
    Desc = "Your damage resistance to all weapons is increased by 15% and regen by 3 for 20 seconds. 80 second cooldown.",
    Icon = "vgui/morbus/brood/icon_brood_screech.png",
    MaxLevel = 1,
    Tier = 3
}

UPGRADE.INVISIBLE_EXTRA = 18
UPGRADES[ 18 ] = {
    Title = "Adaptive Camouflage Upgraded",
    Tree = TREE_UTILITY,
    Desc = "REQUIRES ADAPTIVE CAMOUFLAGE: Upgrades ADAPTIVE CARAPACE to allow invisibility in human form.",
    Icon = "vgui/morbus/brood/icon_brood_question.png",
    MaxLevel = 1,
    Tier = 2
}

UPGRADE.JUMP_EXTRA = 19
UPGRADE.JUMP_EXTRA_AMOUNT = 1
UPGRADES[ 19 ] = {
    Title = "Airborne Locomotion",
    Tree = TREE_UTILITY,
    Desc = "REQUIRES BOLSTERING LEGS: Give (LEVEL) additional jumps.",
    Icon = "vgui/morbus/brood/icon_brood_jump.png",
    MaxLevel = 3,
    Tier = 2
}

UPGRADE.INVISIBLE_EXTRA_EXTRA = 20
UPGRADE.JUMP_EXTRA_EXTRA_AMOUNT = 1
UPGRADES[ 20 ] = {
    Title = "Adaptive Camouflage Ultimate",
    Tree = TREE_UTILITY,
    Desc = "REQUIRES ADAPTIVE CARAPACE AND ADAPTIVE CARAPACE EXTRA: Upgrades ADAPTIVE CARAPACE to allow invisibility while crouched.",
    Icon = "vgui/morbus/brood/icon_brood_question.png",
    MaxLevel = 1,
    Tier = 3
}

UPGRADE.ATTACK_T3 = 21
UPGRADES[ 21 ] = {
    Title = "Enraged Bloodlust",
    Tree = TREE_OFFENSE,
    Desc = "Your damage is increased by 3 and lifesteal by 15 for 20 seconds. On an 80 second cooldown.",
    Icon = "vgui/morbus/brood/icon_brood_question.png",
    MaxLevel = 1,
    Tier = 3
}
