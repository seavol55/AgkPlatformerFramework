/*
 * File name: MovementSystem.agc
 *
 * Description: File that holds all the types and functions related to
 * Moving entities in the screen and in the world map
 *
 * Note: Please keep in mind this system relies on TileMapSystem (to track object in the world/map)
 *       and CollisionSystem (To check when a movement is valid in case object is already colliding)
 *
 */

#include "src/System/SystemConventions.agc"
#include "src/System/TileMapSystem.agc"
#include "src/System/CollisionSystem.agc"



/*
 * Function Name: MVS_SetObjectToCenterScreen
 *
 * Parameters:
 *     spaceObject  = CS_SpaceObject that represents the Entity we want to move
 *     map          = TMS_Map map where the object is located
 *
 * Description: Function that set the object to the center on the screen. Please keep in mind
 *              this functions set the spaceObject in world coordinates in a way that, based on
 *              the camera position (in world coordinates), looks like spaceObject is in the center
 *              of the screen
 */
FUNCTION MVS_SetObjectToCenterScreen(spaceObject REF AS CS_SpaceObject, map REF AS TMS_Map)
    // Calculate center coordinates based on camera pos and dimensions
    xWorldCameraCenter AS FLOAT
    yWorldCameraCenter AS FLOAT
    
    xWorldCameraCenter = map.Camera.XCameraPos + (map.Camera.Width / 2.0) - (spaceObject.BoxCollider.Width / 2.0)
    yWorldCameraCenter = map.Camera.YCameraPos + (map.Camera.Height / 2.0) - (spaceObject.BoxCollider.Height / 2.0)
    
    spaceObject.XPos = xWorldCameraCenter
    spaceObject.YPos = yWorldCameraCenter
ENDFUNCTION


/*
 * Function name: MVS_AddObjectMovement
 * 
 * Parameters:
 *     spaceObject = CS_SpaceObject that represents the Entity we want to move
 *     map         = TMS_Map map where the object is located
 *     x           = amount of movement to perform on x axis
 *     y           = amount of movement to perform on y axis
 *
 * Description: Function that, based on the current position of the spaceObject adds the corresponding
 *              amount of movement provided in the params
 *
 */
FUNCTION MVS_AddObjectMovement(spaceObject REF AS CS_SpaceObject, map REF AS TMS_Map, x AS FLOAT, y AS FLOAT)
    spaceObject.XPos = spaceObject.XPos + x
    spaceObject.YPos = spaceObject.YPos + y
ENDFUNCTION
