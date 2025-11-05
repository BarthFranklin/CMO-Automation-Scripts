-- ==========================================================
--                  / ** Franklin24 ** /
-- Random Land Location: Populates given area with units
-- ==========================================================

-- Units
local unitDBID = 626                   -- replace with your unit’s DB ID
local numUnits = 40                    -- how many units to spawn

-- General
local sideName = 'OpFor'             -- side ownership for units/locations
local lonMin = -120                    -- minimum longitude (positive = East, negative = West)
local lonMax = -111                    -- maximum longitude
local latMin = 30                      -- minimum latitude
local latMax = 35                      -- maximum latitude


---------------------------------------------------------
-- UNIT SPAWNING
---------------------------------------------------------
print('--- Spawning units ---')
local spawnedCount = 0
attempts = 0
local maxAttemptsUnits = numUnits * 10

while spawnedCount < numUnits and attempts < maxAttemptsUnits do
    attempts = attempts + 1

    local lon = lonMin + math.random() * (lonMax - lonMin)
    local lat = latMin + math.random() * (latMax - latMin)
    local alt = World_GetElevation({Latitude = lat, Longitude = lon})

    if alt and alt > 0 then
        local unitName = 'Raiders_' .. tostring(spawnedCount + 1)
        local unit = ScenEdit_AddUnit({
            side = sideName,
            type = 'Facility',
            name = unitName,
            dbid = unitDBID,
            latitude = lat,
            longitude = lon
        })
        if unit then
            spawnedCount = spawnedCount + 1
            print(string.format('Spawned %s at %.4f, %.4f', unitName, lat, lon))
        end
    end
end

print('Units spawned: ' .. spawnedCount)