/*
 * File name: SpriteRendererSystem.agc
 *
 * Description: File that holds all the types and functions related to
 * Drawing sprites in screen (from world coordinates)
 *
 * Note: Please keep in mind this system relies on the assumption that any given
 *       object to draw on screen, its coordinates will be world coordinates
 *       in order to translate them into screen coordinates
 *
 */
#include "src/System/SystemConventions.agc"
#include "src/System/TileMapSystem.agc"
#include "src/System/CollisionSystem.agc"


/*
 * Function Name: SRS_DrawObjectToScreen
 *
 * Parameters:
 *     spaceObject = CS_SpaceObject that represents the Entity we want to draw
 *     map         = TMS_Map map where the object is located
 *     spriteId    = Id of the sprite already loaded in memory that we're gonna change its position
 *
 */
FUNCTION SRS_DrawObjectToScreen(spaceObject REF AS CS_SpaceObject, map REF AS TMS_Map, spriteId AS INTEGER)
    xScreen AS FLOAT
    yScreen AS FLOAT
    
    xScreen = spaceObject.XPos - map.Camera.XCameraPos
    yScreen = spaceObject.YPos - map.Camera.YCameraPos
    
    SetSpritePosition(spriteId, xScreen, yScreen)
    SetSpriteDepth(spriteId, FOREGROUND_LEVEL_DRAW) // Make sure objects are drawn on top of the screen
ENDFUNCTION
