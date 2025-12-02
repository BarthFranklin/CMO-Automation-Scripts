-- ==========================================================
--                  / ** Franklin24 ** /
-- COPY REFERENCE POINTS BETWEEN SIDES 
-- ============================================================

-- ===== USER SETTINGS =====
local sourceSide = "Blue"             -- Side to copy FROM
local targetSide = "Red"              -- Side to copy TO
local prefix     = "RP-"              -- Prefix before the number
local startNum   = 1                  -- Starting number
local endNum     = 44                 -- Ending number
-- ==========================

print("Copying reference points from "..sourceSide.." to "..targetSide)
print("Range: "..prefix..startNum.." to "..prefix..endNum)

for i = startNum, endNum do
    local rpName = prefix .. tostring(i)

    -- Get the RP from the source side
    local rp = ScenEdit_GetReferencePoint({ side = sourceSide, name = rpName })

    if rp ~= nil then
        -- Create same RP on the target side
        ScenEdit_AddReferencePoint({
            side = targetSide,
            name = rpName,
            lat  = rp.latitude,
            lon  = rp.longitude
        })

        print("Copied: " .. rpName .. " at (" .. rp.latitude .. ", " .. rp.longitude .. ")")
    else
        print("Missing: " .. rpName .. " (not found on " .. sourceSide .. ")")
    end
end

print("=== Copy Complete ===")
