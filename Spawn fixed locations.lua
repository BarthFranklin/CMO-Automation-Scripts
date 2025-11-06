-- ==========================================================
--                  / ** Franklin24 ** /
-- Spawn fixed locations
-- ==========================================================

-- ==========================================================
-- User Input
-- ==========================================================
local facilitiesIDs = {174, 4609, 1747, 455}   -- facilities DB IDs
local numLocations = 100                         -- how many locations spawn from the provided list (can be used to limit spawn locations but maintain the list content)
local maxSlope = 100                              -- maximum allowed slope in degrees
local groupSpacing_m = 300                      -- spacing between facilities in meters

-- General
local sideName = 'Civilians'                    -- side ownership for units/locations

-- ==========================================================
-- List of locations with coordinates
-- You can ask ChatGPT to generate a list of locations with lat/lon
-- Thanks to this list you can spawn existing cities, arifields etc
-- ==========================================================
-- You must supply a table like:
local locations = {
    { name = "Mexico location",       latitude = 19.4326,   longitude = -99.1332 },
    { name = "New York",              latitude = 40.7128,   longitude = -74.0060 },
    { name = "Los Angeles",           latitude = 34.0522,   longitude = -118.2437 },
    { name = "Toronto",               latitude = 43.6532,   longitude = -79.3832 },
    { name = "Chicago",               latitude = 41.8781,   longitude = -87.6298 },
    { name = "Houston",               latitude = 29.7604,   longitude = -95.3698 }
}


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

for i = 1, #locations do
    if locSpawned >= numLocations then break end

    local location = locations[i]
    local lat = location.latitude
    local lon = location.longitude

    local info = World_GetLocation({Latitude = lat, Longitude = lon})
    local alt = info and info.elevation or World_GetElevation({Latitude = lat, Longitude = lon})
    local slope = info and info.slope or 0

    if alt and alt > 0 and slope <= maxSlope then
        local groupName = location.name
        print(string.format('Spawning %s at %.4f, %.4f (alt %.1fm, slope %.1f°)', 
                            groupName, lat, lon, alt, slope))

        -- Spawn each facility in this group
        for j, dbid in ipairs(facilitiesIDs) do
            local subLat, subLon = lat, lon
            if j > 1 then
                local bearing = math.random() * 360
                subLat, subLon = movePoint(lat, lon, bearing, groupSpacing_m)
            end

            local name = string.format(groupName)
            local facility = ScenEdit_AddUnit({
                side     = sideName,
                type     = 'Facility',
                name     = name,
                dbid     = dbid,
                latitude = subLat,
                longitude= subLon
            })

            if facility then
                print(string.format('   Spawned %s (DBID %d) at %.4f, %.4f', 
                                    name, dbid, subLat, subLon))
            end
        end

        locSpawned = locSpawned + 1
    else
        print(string.format('   Skipping location %s due to elevation/slope: alt=%.1f slope=%.1f', 
                            location.name, alt or -1, slope))
    end
end

print('Location groups spawned: ' .. locSpawned)

-- ==========================================================
-- RESET EMCON SETTINGS FOR ALL FACILITIES ON SIDE
-- ==========================================================
print('--- Resetting EMCON settings for side: ' .. sideName .. ' ---')
local side = VP_GetSide({ name = sideName })
if side then
    for _, u in pairs(side.units) do
        local fullUnit = ScenEdit_GetUnit({ guid = u.guid })
        if fullUnit and fullUnit.type == 'Facility' then
            fullUnit.obeyEMCON = true
            -- fullUnit:setEMCON('Radar=Passive;OECM=Passive;Sonar=Passive')
            print('   Reset EMCON for: ' .. fullUnit.name)
        end
    end
else
    print('   ERROR: Side not found: ' .. sideName)
end

print('--- EMCON reset complete ---')
