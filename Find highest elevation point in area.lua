-- ==========================================================
--                  / ** Franklin24 ** /
-- Find Highest Elevation Point in area (Adaptive Search) and place facility on top
-- ==========================================================

-- ==========================================================
-- User Input
-- ==========================================================
local rpNames = { 'RP-1', 'RP-2', 'RP-3', 'RP-4' } -- Provide name of all 4 reference points between which you want to find highest elev point.
local facilityID = 1747 -- Facility DBID 
local sideName = 'BluFor' -- Side name
local step = 0.05   -- ~5 km (0.01° ≈ 1.1 km at equator)


-- ==========================================================
-- Helper: Safe numeric conversion (handles comma decimals)
function toNumberSafe(value)
    if type(value) == "string" then
        value = value:gsub(",", ".")
    end
    return tonumber(value)
end

-- Helper: Safe elevation function (requires CMO v1147.27+)
function GetElevation(lat, lon)
    local elev = World_GetElevation({latitude = lat, longitude = lon})
    if elev == nil then return 0 end
    return tonumber(elev)
end

-- Helper: Retrieve reference points
local rpList = ScenEdit_GetReferencePoints({ side=sideName, area = rpNames })
if rpList == nil or #rpList < 1 then
    print("Error: Could not retrieve any reference points.")
    return
end

-- Helper: Function to perform elevation search
function SearchArea(minLat, maxLat, minLon, maxLon, step)
    local bestLat, bestLon, bestElev = minLat, minLon, -9999
    for lat = minLat, maxLat, step do
        for lon = minLon, maxLon, step do
            local elev = GetElevation(lat, lon)
            if elev > bestElev then
                bestElev, bestLat, bestLon = elev, lat, lon
            end
        end
    end
    return bestLat, bestLon, bestElev
end
-- ==========================================================

-- ==========================================================
-- Actual script
-- ==========================================================
-- Extract numeric coordinates (locale-safe)
local lats, lons = {}, {}
print("=== Reference Points Retrieved ===")
for i, p in ipairs(rpList) do
    -- Fallback for alternate field names (lat/lon vs latitude/longitude)
    local lat = p.latitude or p.lat
    local lon = p.longitude or p.lon

    local latNum = toNumberSafe(lat)
    local lonNum = toNumberSafe(lon)

    print(string.format("%d. %s  lat=%s lon=%s", i, p.name, tostring(lat), tostring(lon)))

    if latNum and lonNum then
        table.insert(lats, latNum)
        table.insert(lons, lonNum)
    else
        print("Warning: Invalid coordinates for reference point: " .. tostring(p.name))
    end
end

-- Check we have valid points
if #lats < 1 or #lons < 1 then
    print("Error: No valid coordinates found.")
    return
end

-- Compute bounding box
local minLat, maxLat = lats[1], lats[1]
local minLon, maxLon = lons[1], lons[1]
for i = 2, #lats do
    if lats[i] < minLat then minLat = lats[i] end
    if lats[i] > maxLat then maxLat = lats[i] end
end
for i = 2, #lons do
    if lons[i] < minLon then minLon = lons[i] end
    if lons[i] > maxLon then maxLon = lons[i] end
end

print(string.format("Search area limited to:\n  Lat: %.5f – %.5f\n  Lon: %.5f – %.5f",
    minLat, maxLat, minLon, maxLon))

-- Adaptive refinement search
local bestLat, bestLon, bestElev = SearchArea(minLat, maxLat, minLon, maxLon, step)
local refinements = {0.02, 0.005, 0.001}

for _, s in ipairs(refinements) do
    local half = s * 5
    local latMin = math.max(minLat, bestLat - half)
    local latMax = math.min(maxLat, bestLat + half)
    local lonMin = math.max(minLon, bestLon - half)
    local lonMax = math.min(maxLon, bestLon + half)
    bestLat, bestLon, bestElev = SearchArea(latMin, latMax, lonMin, lonMax, s)
end

-- Place facility only if above sea level
if bestElev <= 0 then
    print(string.format("Highest point (%.1f m) is below or at sea level. Facility not placed.", bestElev))
else
    local fac = ScenEdit_AddUnit({
        type = 'Facility',
        name = 'High Point Facility',
        side = sideName,
        latitude = bestLat,
        longitude = bestLon,
        dbid = facilityID
    })
    print(string.format("Facility placed at %.5f°, %.5f° (%.1f m).",
        bestLat, bestLon, bestElev))
end