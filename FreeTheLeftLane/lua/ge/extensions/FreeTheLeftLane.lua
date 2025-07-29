-- lua/ge/extensions/rightLaneFilter.lua
local M = {}

-- --- config ---
local RIGHT_IS_POSITIVE = true
local DEFAULT_ROAD_WIDTH = 8.0
local MAX_SEARCH_DIST = 60.0
local LOG = 'FreeTheLeftLane'

-- --- vec helpers ---
local UP = {x=0,y=0,z=1}
local function vsub(a,b) return {x=a.x-b.x, y=a.y-b.y, z=a.z-b.z} end
local function vadd(a,b) return {x=a.x+b.x, y=a.y+b.y, z=a.z+b.z} end
local function vmul(a,s) return {x=a.x*s, y=a.y*s, z=a.z*s} end
local function dot(a,b) return a.x*b.x + a.y*b.y + a.z*b.z end
local function len(a) return math.sqrt(dot(a,a)) end
local function norm(a) local l=len(a); if l<1e-9 then return {x=0,y=0,z=0} end; return vmul(a,1/l) end
local function cross(a,b) return {x=a.y*b.z - a.z*b.y, y=a.z*b.x - a.x*b.z, z=a.x*b.y - a.y*b.x} end
local function clamp(x,a,b) if x<a then return a elseif x>b then return x>b and b or x end end
local function interp(a,b,t) return vadd(a, vmul(vsub(b,a), t)) end
local function lerpWidth(ws,i,t) local w1=ws[i]; local w2=ws[i+1] or ws[i]; return (1-t)*w1 + t*w2 end

-- --- DecalRoad cache ---
local roads = {}
local function _toNum(v, fallback) local n=tonumber(v); return n~=nil and n or fallback end

-- The function run when key binding is pressed
local function runMyScript()
  log('I', 'FreeTheLeftLane', 'T Pressed: running Free The Left Lane')
  M.collectDecalRoads()
end

-- Collects all DecalRoad objects in the scene and stores them in the roads table.
local function collectDecalRoads()
  roads = {}
  local ids = scenetree.findClassObjects and scenetree.findClassObjects("DecalRoad") or {}
  for _, id in ipairs(ids) do
    local r = scenetree.findObject(id)
    if r and r.getNodeCount and r:getNodeCount() >= 2 then
      local entry = { obj=r, name=r:getName(), nodes={}, widths={},
                      lanesLeft=_toNum(r:getField("lanesLeft",0),0) or 0,
                      lanesRight=_toNum(r:getField("lanesRight",0),0) or 0 }
      local n = r:getNodeCount()
      for i=0,n-1 do
        local p = (r.getNodePos and r:getNodePos(i)) or (r.getNodePosition and r:getNodePosition(i))
        local w = (r.getNodeWidth and r:getNodeWidth(i)) or (r.getNodeSize and r:getNodeSize(i)) or DEFAULT_ROAD_WIDTH
        if p then table.insert(entry.nodes, {x=p.x,y=p.y,z=p.z}) end
        table.insert(entry.widths, w or DEFAULT_ROAD_WIDTH)
      end
      table.insert(roads, entry)
    end
  end
  log('I', LOG, ('Cached %d DecalRoad(s).'):format(#roads))
end

-- Finds the nearest DecalRoad to a given world position and returns information about it.
local function nearestRoadInfo(worldPos)
  local best, bestD2 = nil, MAX_SEARCH_DIST*MAX_SEARCH_DIST
  for _, rd in ipairs(roads) do
    local ns = #rd.nodes
    for i=1, ns-1 do
      local a, b = rd.nodes[i], rd.nodes[i+1]
      local ab = vsub(b,a); local ab2 = dot(ab,ab)
      if ab2 > 1e-9 then
        local ap = vsub(worldPos, a)
        local t = math.max(0, math.min(1, dot(ap,ab)/ab2))
        local p = interp(a,b,t)
        local d = vsub(worldPos, p)
        local d2 = dot(d,d)
        if d2 < bestD2 then
          local fwd = norm(ab)
          local right = cross(fwd, UP)
          local lateral = dot(d, right)                       -- signed meters from centerline
          local width = lerpWidth(rd.widths, i, t) or DEFAULT_ROAD_WIDTH
          best = { road=rd, point=p, forward=fwd, right=right, width=width, lateral=lateral }
          bestD2 = d2
        end
      end
    end
  end
  return best
end

-- Calculates the index of the right lane based on the width, number of lanes, and lateral signed distance.
local function rightLaneIndex1(width, lanesLeft, lanesRight, lateralSigned)
  local total = math.max(1, lanesLeft + lanesRight)
  local laneWidth = width / total
  local lat = RIGHT_IS_POSITIVE and lateralSigned or -lateralSigned
  local globalFloat = (lat + width*0.5) / laneWidth
  local globalIdx = math.max(0, math.min(total-1, math.floor(globalFloat + 1e-6)))
  local right0 = globalIdx - lanesLeft
  return math.max(1, math.min(lanesRight, right0 + 1)), laneWidth, lat
end

-- Handles vehicle events safely by checking if the vehicle is valid and not player-controlled.
local function safeHandle(tag, vid)
  local ok, err = pcall(function()
    local v = be:getObjectByID(vid)
    if not v or v:isPlayerControlled() then return end

    local pos = v:getPosition()
    local info = nearestRoadInfo(pos)
    if not info then
      return
    end

    local L, R = info.road.lanesLeft, info.road.lanesRight
    if L == 0 and R == 2 then
      local lane1, laneWidth, lat = rightLaneIndex1(info.width, L, R, info.lateral)

      -- Teleport the vehicle out of the way if it's on the left lane.
      if lane1 == 1 then
        log('I', LOG, string.format('Car on wrong lane! car vid: %s', tostring(vid)))
        teleportVidRandom(vid)
        return
      end
    end
  end)
  if not ok then
    log('E', LOG, ('%s handler error: %s'):format(tag, tostring(err)))
  end
end

-- Teleports a vehicle to a random position within a specified radius.
function teleportVidRandom(vid)
  if not __tlr_seeded then
    math.randomseed(os.time() % 2147483647)
    __tlr_seeded = true
  end

  local v = be:getObjectByID(vid)
  if not v then return false, "vehicle not found" end

  local p = v:getPosition()
  local minR, maxR = 300, 800
  local r   = minR + math.random() * (maxR - minR)
  local ang = math.random() * (2 * math.pi)

  local tx = p.x + r * math.cos(ang)
  local ty = p.y + r * math.sin(ang)
  local tz = p.z + 0.5
   log('I', LOG, string.format('Teleported %s out of the way!!', tostring(vid)))
  v:setPosition({x=tx, y=ty, z=tz})
  return true
end

-- hooks
local function onExtensionLoaded()  collectDecalRoads() end
local function onVehicleResetted(vid) safeHandle('resetted', vid) end

M.onExtensionLoaded            = onExtensionLoaded
M.onMissionLoaded              = onMissionLoaded
M.onVehicleSpawned             = onVehicleSpawned
M.onVehicleResetted            = onVehicleResetted
M.onTrafficVehicleSpawned      = onTrafficVehicleSpawned
M.onTrafficVehicleReplaced     = onTrafficVehicleReplaced
M.teleportVidRandom            = teleportVidRandom
M.runMyScript                  = runMyScript
M.collectDecalRoads            = collectDecalRoads
return M
