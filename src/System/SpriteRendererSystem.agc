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
FUNCTION SRS_DrawObjectToScreen(spaceObject REF AS CS_SpaceObject, map REF AS TMS_Map)
    xScreen AS FLOAT
    yScreen AS FLOAT
    
    xScreen = SRS_WorldToScreenCoordinateX(spaceObject, map)
    yScreen = SRS_WorldToScreenCoordinateY(spaceObject, map)
    
    SetSpritePosition(spaceObject.SpriteId, xScreen, yScreen)
    SetSpriteDepth(spaceObject.SpriteId, FOREGROUND_LEVEL_DRAW)
    DrawBox(xScreen, yScreen, GetSpriteWidth(spaceObject.SpriteId), GetSpriteHeight(spaceObject.SpriteId), 120,120,120,0,1)
ENDFUNCTION

/*
 * Function Name: SRS_WorldToScreenCoordinateX
 *
 * Parameters:
 *     spaceObject = CS_SpaceObject to calculate screen coordinates
 *     map         = TMS_Map map where the object is moving
 *
 * Description: Function to convert world coordinates from a space object into equivalent screen cooordinates
 *
 */
FUNCTION SRS_WorldToScreenCoordinateX(spaceObject REF AS CS_SpaceObject, map REF AS TMS_Map)
    result AS FLOAT
    result = spaceObject.XPos - map.Camera.XCameraPos
ENDFUNCTION result

/*
 * Function Name: SRS_WorldToScreenCoordinateY
 *
 * Parameters:
 *     spaceObject = CS_SpaceObject to calculate screen coordinates
 *     map         = TMS_Map map where the object is moving
 *
 * Description: Function to convert world coordinates from a space object into equivalent screen cooordinates
 *
 */
FUNCTION SRS_WorldToScreenCoordinateY(spaceObject REF AS CS_SpaceObject, map REF AS TMS_Map)
    result AS FLOAT
    result = spaceObject.YPos - map.Camera.YCameraPos
ENDFUNCTION result
