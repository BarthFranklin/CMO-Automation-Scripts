-- ==========================================================
--                  / ** Franklin24 ** /
-- Spawn units with waypoints: Populates given area with units and assign them mission to roam around
-- ==========================================================

-- ==== USER SETTINGS ====
local unitDBID = 2943             -- database ID for the unit
local numUnits = 40              -- how many units to spawn
local sideName = 'OpFor'         -- which side owns the spawned units

-- These 4 reference points must already exist in the scenario
local refPointNames = {
    "RP-1",
    "RP-2",
    "RP-3",
    "RP-4"
}

-- OPTIONAL roaming mission settings
local assignRoamingMission = true  -- set to true to make units patrol
local distanceBetweenRP = 40000  -- meters between patrol waypoints
local numberOfRP = 5

-- ==========================================

print('--- Spawning units based on reference area ---')

-- --- Get the coordinates of the reference points ---
local refPoints = {}
for i, rpName in ipairs(refPointNames) do
    local rp = ScenEdit_GetReferencePoint({side = sideName, name = rpName})
    if not rp then
        print("ERROR: Reference point '" .. rpName .. "' not found for side '" .. sideName .. "'.")
        return
    end
    table.insert(refPoints, {lat = rp.latitude, lon = rp.longitude})
end

if #refPoints ~= 4 then
    print("ERROR: You must define exactly 4 valid reference points.")
    return
end

-- --- Helper: Find bounding box ---
local latMin, latMax = math.huge, -math.huge
local lonMin, lonMax = math.huge, -math.huge
for _, rp in ipairs(refPoints) do
    if rp.lat < latMin then latMin = rp.lat end
    if rp.lat > latMax then latMax = rp.lat end
    if rp.lon < lonMin then lonMin = rp.lon end
    if rp.lon > lonMax then lonMax = rp.lon end
end

-- --- Helper: Point-in-polygon test (for convex 4-point area) ---
local function isInside(lat, lon, poly)
    local inside = false
    local j = #poly
    for i = 1, #poly do
        if ((poly[i].lon > lon) ~= (poly[j].lon > lon)) and
           (lat < (poly[j].lat - poly[i].lat) * (lon - poly[i].lon) / (poly[j].lon - poly[i].lon) + poly[i].lat) then
            inside = not inside
        end
        j = i
    end
    return inside
end

-- --- Helper: Random point within reference area ---
local function randomPointWithin()
    for attempt = 1, 1000 do
        local lat = latMin + math.random() * (latMax - latMin)
        local lon = lonMin + math.random() * (lonMax - lonMin)
        if isInside(lat, lon, refPoints) then
            local alt = World_GetElevation({Latitude = lat, Longitude = lon})
            if alt and alt > 0 then
                return lat, lon
            end
        end
    end
    return nil, nil
end

-- --- Helper: Generate random nearby point (for roaming missions) ---
local function randomNearbyPoint(lat, lon, maxDistance_m)
    local R = 6371000
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
    return math.deg(newLatRad), math.deg(newLonRad)
end

-- --- Spawn Units ---
local spawnedCount = 0
local attempts = 0
local maxAttemptsUnits = numUnits * 10

while spawnedCount < numUnits and attempts < maxAttemptsUnits do
    attempts = attempts + 1
    local lat, lon = randomPointWithin()

    if lat and lon then
        local unitName = sideName.. tostring(spawnedCount + 1)
        local unit = ScenEdit_AddUnit({
            side = sideName,
            type = 'Facility',  -- change to 'Aircraft', 'Ship', etc.
            name = unitName,
            dbid = unitDBID,
            latitude = lat,
            longitude = lon
        })

        if unit then
            spawnedCount = spawnedCount + 1
            print(string.format('Spawned %s at %.4f, %.4f', unitName, lat, lon))

            -- Optional roaming mission
            if assignRoamingMission then
                local missionName = "Wander_" .. unitName
                local referencePoints = {}

                for i = 1, numberOfRP do
                    local wpLat, wpLon = randomNearbyPoint(lat, lon, distanceBetweenRP)
                    local rpName = string.format("%s_RP_%d", unitName, i)
                    local rp = ScenEdit_AddReferencePoint({
                        name = rpName,
                        latitude = wpLat,
                        longitude = wpLon,
                        side = sideName
                    })
                    if rp then table.insert(referencePoints, rpName) end
                end

                local mission = ScenEdit_AddMission(sideName, missionName, "Patrol", {
                    type = "LAND",
                    zone = referencePoints,
                    repeatAfterLast = true
                })

                if mission then
                    ScenEdit_AssignUnitToMission(unit.guid, mission.name)
                    print("   Assigned mission: " .. missionName)
                end
            end
        end
    end
end

print('Units spawned: ' .. spawnedCount)
