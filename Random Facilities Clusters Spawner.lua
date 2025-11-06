-- ==========================================================
--                  / ** Franklin24 ** /
-- Random Facilities Clusters Spawner: 
-- -- Part 1:
-- -- -- Populates given area with set of defined facilities
-- -- Part 2:
-- -- -- Enforce use of ENCOM settings
-- ==========================================================

-- ==========================================================
-- User Input
-- ==========================================================
-- Locations (each group will contain one of each facility ID below)
local facilitiesIDs = {174, 4609, 1747, 455}  -- example array of facility DB IDs (in this case - City, Comms Center, Basic radar, Industry plant)
local numLocations = 10                       -- how many location groups to spawn
local maxSlope = 0                            -- max allowed slope in degrees  *** To be validated ***
local groupSpacing_m = 300                    -- spacing between facilities in meters

-- General
local sideName = 'Civilians'           -- side ownership for units/locations
local lonMin = -120                    -- minimum longitude (positive = East, negative = West)
local lonMax = -111                    -- maximum longitude
local latMin = 30                      -- minimum latitude
local latMax = 35                      -- maximum latitude


-- ==========================================================
-- Helper: Move a coordinate (lat, lon) by distance (m) and bearing (°)
-- ==========================================================
local function movePoint(lat, lon, bearing, distance_m)
    local R = 6371000  -- Earth radius in meters
    local latRad = math.rad(lat)
    local lonRad = math.rad(lon)
    local brng = math.rad(bearing)
    local distR = distance_m / R

    local newLat = math.asin(math.sin(latRad) * math.cos(distR) +
                             math.cos(latRad) * math.sin(distR) * math.cos(brng))
    local newLon = lonRad + math.atan2(math.sin(brng) * math.sin(distR) * math.cos(latRad),
                                       math.cos(distR) - math.sin(latRad) * math.sin(newLat))
    return math.deg(newLat), math.deg(newLon)
end

-- ==========================================================
-- LOCATION GROUP SPAWNING
-- ==========================================================
print('--- Spawning location groups ---')
local locSpawned = 0
local attempts = 0
local maxAttempts = numLocations * 10

while locSpawned < numLocations and attempts < maxAttempts do
    attempts = attempts + 1

    local lon = lonMin + math.random() * (lonMax - lonMin)
    local lat = latMin + math.random() * (latMax - latMin)
    local info = World_GetLocation({Latitude = lat, Longitude = lon})
    local alt = info and info.elevation or World_GetElevation({Latitude = lat, Longitude = lon})
    local slope = info and info.slope or 0

    if alt and alt > 0 and slope <= maxSlope then
        local groupName = 'LocationGroup_' .. tostring(locSpawned + 1)
        print(string.format('Spawning %s base at %.4f, %.4f (slope %.1f°)', groupName, lat, lon, slope))

        -- Spawn each facility in this group
        for i, dbid in ipairs(facilitiesIDs) do
            local subLat, subLon = lat, lon
            if i > 1 then
                -- offset subsequent facilities randomly around base
                local bearing = math.random() * 360
                subLat, subLon = movePoint(lat, lon, bearing, groupSpacing_m)
            end

            local name = string.format('%s_Facility_%d', groupName, i)
            local facility = ScenEdit_AddUnit({
                side = sideName,
                type = 'Facility',
                name = name,
                dbid = dbid,
                latitude = subLat,
                longitude = subLon
            })

            if facility then
                print(string.format('   Spawned %s (DBID %d) at %.4f, %.4f', name, dbid, subLat, subLon))
            end
        end

        locSpawned = locSpawned + 1
    end
end
print('Location groups spawned: ' .. locSpawned)

-- ==========================================================
-- RESET EMCON SETTINGS FOR ALL FACILITIES ON SIDE (FULL WRAPPER VERSION)
-- ==========================================================
print('--- Resetting EMCON settings for side: ' .. sideName .. ' ---')

local side = VP_GetSide({name = sideName})
if side then
    for _, u in pairs(side.units) do
        local fullUnit = ScenEdit_GetUnit({guid = u.guid})
        if fullUnit then
            -- Only apply to facilities
            if fullUnit.type == 'Facility' then
                -- Force it to obey its EMCON doctrine immediately
                fullUnit.obeyEMCON = true

                -- Explicitly set EMCON state
                -- fullUnit:setEMCON('Radar=Passive;OECM=Passive;Sonar=Passive')

                print('   Reset EMCON for: ' .. fullUnit.name)
            end
        end
    end
else
    print('   ERROR: Side not found: ' .. sideName)
end

print('--- EMCON reset complete ---')
