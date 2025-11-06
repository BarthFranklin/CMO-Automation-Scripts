-- ==========================================================
--                  / ** Franklin24 ** /
-- Scenario Setup: Factions, relations, doctrines
-- ==========================================================
-- There's no need to use this script as a whole. Headers explain what can you find below it.
-- You can just take a part of it that is relevant to you and paste it in LUA console in CMO with proper data.
-- ==========================================================

-- ==========================================================
-- Create sides
-- ==========================================================
local bluSide = 'BluFor'
local redSide = 'OpFor'
local neutralSide = 'Civilians'
ScenEdit_AddSide({side = bluSide})
ScenEdit_AddSide({side = redSide})
ScenEdit_AddSide({side = neutralSide})

-- ==========================================================
-- Set side relationships 
-- ==========================================================
-- 0 = Neutral (N) -- default - newly created sides will all be neutral to each other
-- 1 = Friendly (F)
-- 2 = Unfriendly (U)
-- 3 = Hostile (H)
-- 4 = Unknown (X)
-- ==========================================================
ScenEdit_SetSidePosture(bluSide, redSide, 'H')
ScenEdit_SetSidePosture(redSide, bluSide, 'H')

-- ==========================================================
-- Configure Doctrine
-- ==========================================================
-- Here you can find whole doctrine object defined but commented out.
-- If you want to change only specific doctrines you can just uncomment the line and pass `doctirne` object with properties that are relevant to you - there's no need to use all of them
--  ** IMPORTANT **
-- You can also set up doctrines using GUI as usual, then use `print(ScenEdit_GetDoctrine())` and use that object to quickly apply it to other sides using `ScenEdit_SetDoctrine()`
-- ==========================================================
local doctrine = {
    -- jettison_ordnance = 0,
    -- weapon_state_planned = 0,
    -- navigation_surface = 0, 
    -- use_sams_in_anti_surface_mode = 0,
    -- fuel_state_planned = 0,
    weapon_control_status_surface = 0,
    -- ignore_emcon_while_under_attack = 1,
    -- bingo_threshold = 3,
    -- dive_on_threat = 0,
    -- navigation_land = 0,
    -- recharge_on_attack = 10,
    -- weapon_control_status_subsurface = 1,
    -- maintain_standoff = 1,
    -- weapon_state_rtb = 1,
    -- deploy_on_fuel = 5,
    -- recharge_on_patrol = 60,
    -- deploy_on_damage = 1,
    -- refuel_unrep_allied = 0,
    -- withdraw_on_defence = 2,
    -- withdraw_on_attack = 2,
    -- fuel_state_rtb = 2,
    -- quick_turnaround_for_aircraft = 1,
    -- dipping_sonar = 0,
    -- use_refuel_unrep = 0,
    -- use_aip = 1,
    -- withdraw_on_fuel = 3,
    -- ignore_plotted_course = 0,
    -- withdraw_on_damage = 4,
    -- StrikeMemberFocus = 0,
    -- weapon_control_status_air = 1,
    -- deploy_on_attack = 5,
    -- gun_strafing = 0,
    -- use_nuclear_weapons = 0,
    -- engage_opportunity_targets = 1,
    -- kinematic_range_for_torpedoes = 2,
    weapon_control_status_land = 0,
    -- unrep_selection = 0,
    -- bvr_logic = 1,
    engaging_ambiguous_targets = 1,
    -- automatic_evasion = 1,
    -- use_wp_missile_in_anti_surface_mode = 0,
    -- avoid_contact = 0,
    -- air_operations_tempo = 0,
    -- navigation_sub_surface = 0,
    -- deploy_on_defence = 5 
}

ScenEdit_SetDoctrine({side = bluSide}, doctrine)
ScenEdit_SetDoctrine({side = redSide}, doctrine)
ScenEdit_SetDoctrine({side = neutralSide}, doctrine)

-- ==========================================================
-- Configure EMCON
-- ==========================================================
local active = 'Radar=Active;Sonar=Active;OECM=Active'
local passive = 'Radar=Passive;Sonar=Passive;OECM=Passive'

ScenEdit_SetEMCON('Side', bluSide, passive)
ScenEdit_SetEMCON('Side', redSide, active)
ScenEdit_SetEMCON('Side', neutralSide, active)