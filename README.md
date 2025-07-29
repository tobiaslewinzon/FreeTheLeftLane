# FreeThe~~Nipple~~LeftLane!
For high speed cruising on the Autobahn without cars blocking the left lane (most of the time, anyways).

## What does this do?
It's easier to explain in pseudocode:
1) Hooks `onVehicleResetted(vid)` which runs every time AI Traffic spawns a car.
2) Runs its coordinates against some cached decal road lanes map I don't even understand.
3) If the car is on the left lane, it immediately teleports it to some random coordinate on the level (or out of the level :D)
4) A maniac can now pass by at 260 km/h (you).
 
 This is my first Lua script ever. I basically put this together on a windy Saturday night, maybe a little bit high, fine-prompting ChatGTP and Cursor to get a smooth and fast Autobahn drive on this magnificent map. So go easy on me. Any help is welcome!
## How to install
Drag FreeTheLeftLane.zip to your repo folder.
## How to use
Press "t" (letter T) on the keyboard.
If you want to change the binding you can do so in Settings -> Controls -> Search for "Free The"
 
## Beware of:
- The script only acts when cars are spawned. It cannot intervene on an AI Traffic vehicle suicidal decision of switching lanes on the way of a maniac going 300 km/h. 
- Spawn many traffic cars. Like 10-15. Remember that maybe half of them will be constantly teleporting to another galaxy.
- I don't know if this has a performance impact.

## After
https://www.youtube.com/watch?v=tYksjKD_ov8

## Before
https://www.youtube.com/watch?v=NwLI3jbddNw
