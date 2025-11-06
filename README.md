# Command: Modern Operations Automation Scripts

I really like get things automated so with help of ChatGPT I've created a few scripts for `Command: Modern Operations (CMO)` that helps me set up basic things.
- Each script is documented at the top with inline comments
- Copy-paste ready.

If you have some scripts that you want to share with community feel free to create a pull request!


## Currently this repo includes
- Scenario Setup (factions, relations, doctrines)
- Random Facilities Clusters Spawner
- Spawn units with waypoints (units + optional roaming missions)
- Find Highest Elevation Point in the area (Adaptive Search) and place facility on top

## On my TODO list:
- Upgrade `Spawn units` script to allow for array of units instead of single unit type
- Try to experiment with vehicles mission behavior to handle fuel usage.
- Optionally look into slope handling for facility placement on steep terrain because I had location spawned on mountain slope.

## Currently working on:
- Ships sailing from harbor to harbor.
- Predefined convoys that constantly travels between locations

### Scenario Setup
Allows to quickly create a three simple factions with specific doctrines

### Random Facilities Clusters Spawner
This script will quickly populate given Longitude and Latiude range with group of defined facilities.
After spawning it will enforce current EMCON on all facilities. 

### Spawn units with waypoints
Spawn `N` number of units randomly in given Longitude and Latiude range and optionally assign each a roaming/patrol mission.

**Limitations / Notes**
- Tested on land infantry units
- Assigning a roaming mission to vehicles may lead to units get stuck when fuel is depleted

### Unit Spawner
Actually will be removed in the next iteration. Use the one above instead as it's upgraded version

### How to use
1. Edit the top of the chosen script and set:
   - DBID(s) for units/facilities
   - area bounds (lonMin, lonMax, latMin, latMax)
   - counts (numUnits/numLocations) and other parameters
2. In CMO paste script content into Lua Script Console (CTRL + SHIFT + C).
4. Adjust parameters and repeat as needed.

---
