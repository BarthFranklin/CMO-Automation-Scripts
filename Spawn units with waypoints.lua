-- ==========================================================
--                  / ** Franklin24 ** /
-- Spawn units with waypoints: Populates given area with units and assign them missions to roam around
-- ==========================================================

-- Units
local unitDBID = 626              -- replace with your unit’s DB ID
local numUnits = 40               -- how many units to spawn

-- OPTIONAL -- 
-- -- If set to TRUE - will spawn unit with assigned mission to just roam arond
-- --  ** IMPORTANT ** -- --
-- -- Only tested with infantry - if you use vehicles they will probably stop when fuel ends
-- -- When I'll have more time I'll try to mitigate that problem
local assignRoamingMission = true -- if true, assign wandering mission
local distanceBetweenRP = 40000
local numberOfRP = 5

-- General
local sideName = 'OpFor' -- side ownership for units/locations
local lonMin = -120      -- minimum longitude (negative = West)
local lonMax = -111      -- maximum longitude
local latMin = 30        -- minimum latitude
local latMax = 35        -- maximum latitude

---------------------------------------------------------
-- UNIT SPAWNING
---------------------------------------------------------
print('--- Spawning units ---')
local spawnedCount = 0
local attempts = 0
local maxAttemptsUnits = numUnits * 10

-- Helper: generate random nearby point
local function randomNearbyPoint(lat, lon, maxDistance_m)
    local R = 6371000  -- Earth radius in meters
    local isAboveSeaLevel = false
    local newLat, newLon = 0, 0
    local attempts = 0
    local maxAttempts = 1000  -- safety limit to prevent infinite loop

    while not isAboveSeaLevel and attempts < maxAttempts do
        attempts = attempts + 1

        local bearing = math.random() * 360
        local distance = math.random() * maxDistance_m
        local latRad = math.rad(lat)
        local lonRad = math.rad(lon)
        local brng = math.rad(bearing)
        local distR = distance / R

        local newLatRad = math.asin(math.sin(latRad) * math.cos(distR) +
                                    math.cos(latRad) * math.sin(distR) * math.cos(brng))
        local newLonRad = lonRad + math.atan2(math.sin(brng) * math.sin(distR) * math.cos(latRad),
                                              math.cos(distR) - math.sin(latRad) * math.sin(newLatRad))

        -- Convert radians to degrees before checking elevation!
        newLat = math.deg(newLatRad)
        newLon = math.deg(newLonRad)

        local alt = World_GetElevation({ Latitude = newLat, Longitude = newLon })
        if alt and alt > 0 then
            isAboveSeaLevel = true
        end
    end

    if not isAboveSeaLevel then
        print("WARNING: Could not find above-sea-level point after " .. attempts .. " attempts.")
    end

    return newLat, newLon
end


while spawnedCount < numUnits and attempts < maxAttemptsUnits do
    attempts = attempts + 1

    local lon = lonMin + math.random() * (lonMax - lonMin)
    local lat = latMin + math.random() * (latMax - latMin)
    local alt = World_GetElevation({ Latitude = lat, Longitude = lon })

    if alt and alt > 0 then
        local unitName = 'Raiders_' .. tostring(spawnedCount + 1)
        local unit = ScenEdit_AddUnit({
            side = sideName,
            type = 'Facility', -- change to 'Aircraft', 'Ship', etc. if needed
            name = unitName,
            dbid = unitDBID,
            latitude = lat,
            longitude = lon
        })
        if unit then
            spawnedCount = spawnedCount + 1
            print(string.format('Spawned %s at %.4f, %.4f', unitName, lat, lon))

            -- Assign roaming mission if enabled
            if assignRoamingMission then
                local missionName = "Wander around " .. unitName
                local referencePoints = {}

                -- Generate random reference points around spawn
                for i = 1, numberOfRP do
                    local wpLat, wpLon = randomNearbyPoint(lat, lon, distanceBetweenRP)
                    local rpName = string.format("%s_RP_%d", unitName, i)

                    -- Create reference point
                    local rp = ScenEdit_AddReferencePoint({
                        name = rpName,
                        latitude = wpLat,
                        longitude = wpLon,
                        side = sideName
                    })

                    if rp then
                        table.insert(referencePoints, rpName)
                    else
                        print("   Failed to create reference point: " .. rpName)
                    end
                end

                -- Create the patrol mission
                local mission = ScenEdit_AddMission(
                    sideName,
                    missionName,
                    "Patrol",
                    {
                        type = "LAND",
                        zone = referencePoints,
                        repeatAfterLast = true
                    }
                )

                if mission then
                    -- Assign the unit to the mission
                    local assigned = ScenEdit_AssignUnitToMission(unit.guid, mission.name, false)
                    if assigned then
                        print("   Assigned roaming mission: " .. missionName)
                    else
                        print("   Failed to assign unit " .. unitName .. " to mission")
                    end
                else
                    print("   Failed to create mission for " .. unitName)
                end
            end
        end
    end
end

print('Units spawned: ' .. spawnedCount)
