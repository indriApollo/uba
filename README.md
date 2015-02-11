# [uba] Utimate Battle Arena

This mod aims to become the utimate battle arena for Minetest servers.
It offers the core functionalities of an arena which can be completed with additional mods via a global namespace.

**The commands :**
- Player commands :

  - ```/uba join <arena_name>``` Join the arena <arena_name>
  - ```/uba leave``` Leave the arena you are playing in. The player can leave at any time.
  - ```/uba vote``` The battle won't start until the arena is full. The players can vote to start earlier. The votes are available 60 secs after the opening of the arena.
  - ```/uba list``` Returns a list of all the arenas with their name, number of players ans status

- Admin commands (needs the 'uba' privilege) :

   - ```/uba new <arena_name>``` Create a new arena <arena_name> in the worldedit selection. Returns the arena nodes in the catsers inventory.
   - ```/uba save``` Save the arena you are editing. This also enables the arena.
   - ```/uba edit <arena_name>``` Edit an existing arena. Returns the arena nodes in the casters inventory. This will also kick all the players if used on an active arena.
   - ```/uba disable <arena_name>``` Disable the arena <arena_name>. This will also kick all the players if used on an active arena. The disable flag is set in arenas.conf
   - ```/uba additem <arena_name> <itemstring> <count>``` Adds the given tool (itemstring) to the arena's items.conf with the given count.
   - ```/uba rmitem <arena_name> <itemstring>``` Removes the given tool (itemstring) from the arena's items.conf /!\ Broken due to this Minetest [bug](https://github.com/minetest/minetest/issues/2264)

**HOWTO**

First Protect the area where your arena will be build. You can use https://forum.minetest.net/viewtopic.php?id=7239 .
Then select a region with worledit using ```//pos1``` and ```//pos2``` and execute ```/uba new <arena_name>```. Walls will be automatically
 build around your selection to demarcate the arena.
 You can now place the slabs and arena chests. When you are ready, use ```/uba save``` to save and enable the arena. Your players can now enjoy the newly build arena.
 
 **Notes**
 
- Chest: the special arena chest will be randomly refilled with the content of items.conf after each round. These chests can only be destroyed by their placer (most likely the admin)

- Slab: the special arena slabs are used as spawnpoints for the incoming players. These slabs can only be destroyed by their placer (most likely the admin)

- Wall: the arena wall can only be removed with worledit. This is to avoid that players can dig it and escape before the server checks for dig permission (lag)

**Privileges :**
- uba

**Depends :**
- default
- worldedit
- stairs

**LICENCE**
- lgpl 2.1
