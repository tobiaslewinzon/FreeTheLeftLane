# FreeTheLeftLane!
BeamngDrive script mod that prevents AI traffic cars to spawn on the fast lane. 
It is designed for the Autobahn 57k mod, but should work on most roads with two lanes. Download mod and see thread [here](https://www.beamng.com/threads/autobahn-57k.102500/page-9#:~:text=the%20experience%20alot-,I%20created%20a%20little%20script%20that%20disappears%20AI%20Traffic%20cars%20that%20spawn%20on%20the%20left%20lane.%20I%20will%20work%20on%20future%20updates%2C%20let%20me%20know%20how%20it%20feels!%0APress%20%22T%22%20(letter%20t)%20to%20start%20the%20script.%20You%20can%20change%20in%20Settings%20%2D%3E%20Controls,-Attached%20Files%3A). 

## What does this do?
It's easier to explain the algorithm:
1) Cahes and maps all decal road lanes coordinates.
2) Hooks `onVehicleResetted(vid)` which runs every time AI Traffic spawns a car.
3) Runs vehicle coordinates against the mapped lane coordinates.
4) If the car is on the left lane, it immediately teleports it to some random coordinate on the level (or out of the level :D)
5) A maniac can now pass by at 300 km/h (you).
 
 This is my first Lua script ever. I basically put this together on a rainy Saturday night, fine-prompting ChatGTP and Cursor to get a smooth and fast Autobahn drive on this magnificent map. So go easy on me. Any help is welcome!
## How to install
Put FreeTheNextLane.zip in your repo folder.
## How to use
Press "t" (letter T) on the keyboard.
If you want to change the binding you can do so in Settings -> Controls -> Search for "Free The"
 
## Beware of:
- The script only acts when cars are spawned. It cannot intervene on an AI Traffic vehicle suicidal decision of switching lanes on the way of a maniac going 300 km/h. 
- Spawn many traffic cars. Like 10-15. Remember that maybe half of them will be constantly teleporting to another galaxy.
- It's very probable this has a huge performance impact. I didn't measure it though.

## Before
https://www.youtube.com/watch?v=NwLI3jbddNw

## After
https://www.youtube.com/watch?v=tYksjKD_ov8
