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


TYPE MVS_MovementResult
	xAmount AS FLOAT
	yAmount AS FLOAT
ENDTYPE

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
    
    xWorldCameraCenter = map.Camera.XCameraPos + (map.Camera.Width / 2.0) - (GetSpriteWidth(spaceObject.SpriteId) / 2.0)
    yWorldCameraCenter = map.Camera.YCameraPos + (map.Camera.Height / 2.0) - (GetSpriteHeight(spaceObject.SpriteId) / 2.0)
    
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


/*
 * Function Name: MVS_GetValidMovementInWorld
 *
 * Parameters:
 *     spaceObject = CS_SpaceObject that represents the entity we want to move
 *     map         = TMS_Map map where the object is located
 *     result      =  MVS_MovementResult that contains the amount of movement we want to perform
 *
 * Description: Function that checks if the amount of movement we want to perform will result in a collision
 *              with a tile in the map, and if collides, calculate the correct amount of movement to perform
 *              to not collide with the tile
 */
FUNCTION MVS_GetValidMovementInWorld(spaceObject REF AS CS_SpaceObject, map REF AS TMS_Map, result REF AS MVS_MovementResult)    
    xOriginal AS FLOAT
    yOriginal AS FLOAT
    xFinal AS FLOAT
    yFinal AS FLOAT
    
    xTile AS INTEGER
    xTileEnd AS INTEGER
    yTile AS INTEGER
    yTileEnd AS INTEGER
    
    xTileCamera AS INTEGER
    yTileCamera AS INTEGER
    
    // Assume object won't be colliding with a tile and hence will be able to perform full movement
    xFinal = result.xAmount
    yFinal = result.yAmount
    
    // Step 1: Save original position for the object to calculate valid coordinates
    xOriginal = spaceObject.XPos
    yOriginal = spaceObject.YPos
    
    // Step 2: Calculate The columns and rows where the object collides after the movement
    spaceObject.XPos = spaceObject.XPos + xFinal
    spaceObject.YPos = spaceObject.YPos + yFinal
    SRS_DrawObjectToScreen(spaceObject, map)
    
    // Step 3: Based from world coordinates, calculate the column indexes and row indexes where the object
    // is located
    xTile = Floor(spaceObject.XPos / (map.TileSize * 1.0))
    xTileEnd = Floor((spaceObject.XPos + GetSpriteWidth(spaceObject.SpriteId)) / (map.TileSize * 1.0))
    
    yTile = Floor(spaceObject.YPos / (map.TileSize * 1.0))
    yTileEnd = Floor((spaceObject.YPos + GetSpriteHeight(spaceObject.SpriteId)) / (map.TileSize * 1.0))
    
    // Step 4: Calculate the column and row index where the camera is located to draw the map portion
    xTileCamera = Floor(map.Camera.XCameraPos / (map.TileSize * 1.0))
    yTileCamera = Floor(map.Camera.YCameraPos / (map.TileSize * 1.0))
    
    IF (xTileEnd >= map.Width)
        xTileEnd = map.Width - 1
    ENDIF
    
    IF (yTileEnd >= map.Height)
        yTileEnd = map.Height - 1
    ENDIF
    
    
    FOR x = yTile TO yTileEnd
	    FOR y = xTile TO xTileEnd
			// Check if the object is colliding with the neares tiles that are surronding him
		    IF (GetSpriteCollision(spaceObject.SpriteId, map.SpriteData[(x - yTileCamera), (y - xTileCamera)]) AND map.Data[x, y].Walkable = FALSE)
				
				xSubstract AS FLOAT
				ySubstract AS FLOAT
				
				xCollision AS FLOAT
				yCollision AS FLOAT
				
				/*
				 * Case: Given
				 *     O = object we want to perform the movement
				 *     T = tile where the object is colliding with
				 *
				 * The amount of overlap will be given by (taking T as our reference point)
				 *     xCollision (x Overlap) = (top left corner of T) - (top left corner of O)
				 *     yCollision (y Overlap) = (top left corner of T) - (top left corner of O)
				 *
				 * If xCollision > 0 means O is hitting T with his right side
				 * If xCollision < 0 means O is hitting T with his left side
				 *
				 * If yCollision > 0 means O is hitting T with his bottom side
				 * If yCollision < 0 means O is hitting T with his top side
				 *
				 * Based from this, to calculate the amount of movement we have to add/remove to make
				 * O don't hit T will be given by the following formulas
				 *
				 * when O hits T with his right side  = -(Oxpos + Owidth - Txpos)
				 * when O hits T with his left side   =  (Txpos + Twidth - Oxpos)
				 * when O hits T with his bottom side = -(Oypos + Oheight - Typos)
				 * when O hits T with his top side    =  (Typos + Theight - Oypos)
				 */
				xCollision = GetSpriteX(map.SpriteData[(x - yTileCamera), (y - xTileCamera)]) - GetSpriteX(spaceObject.SpriteId)
				yCollision = GetSpriteY(map.SpriteData[(x - yTileCamera), (y - xTileCamera)]) - GetSpriteY(spaceObject.SpriteId)
				xSubstract = 0
				ySubstract = 0
				
				// Check how is colliding horizontally
				IF (xCollision > 0 AND xFinal <> 0) // Space object is colliding from his right side
					xSubstract = -((GetSpriteX(spaceObject.SpriteId) + GetSpriteWidth(spaceObject.SpriteId)) - GetSpriteX(map.SpriteData[(x - yTileCamera), (y - xTileCamera)]) + COLLISION_MARGIN)
				ELSEIF (xCollision < 0 AND xFinal <> 0) // Space object is colliding from his left ide
					xSubstract = ((GetSpriteX(map.SpriteData[(x - yTileCamera), (y - xTileCamera)]) + GetSpriteWidth(map.SpriteData[(x - yTileCamera), (y - xTileCamera)])) - GetSpriteX(spaceObject.SpriteId) + COLLISION_MARGIN)
				ENDIF
				
				// Check how is colliding vertically
				IF (yCollision > 0 AND yFinal <> 0) // Space object is colliding from his below
					ySubstract = -((GetSpriteY(spaceObject.SpriteId) + GetSpriteHeight(spaceObject.SpriteId)) - GetSpriteY(map.SpriteData[(x - yTileCamera), (y - xTileCamera)]) + COLLISION_MARGIN)
				ELSEIF (yCollision < 0 AND yFinal <> 0) // Space object is colliding from his upper side
					ySubstract = ((GetSpriteY(map.SpriteData[(x - yTileCamera), (y - xTileCamera)]) + GetSpriteHeight(map.SpriteData[(x - yTileCamera), (y - xTileCamera)])) - GetSpriteY(spaceObject.SpriteId) + COLLISION_MARGIN)
				ENDIF
				
				xFinal = xFinal + xSubstract
				yFinal = yFinal + ySubstract
				
				EXIT
	        ENDIF
	    NEXT y
    NEXT x
    
    result.xAmount = xFinal
    result.yAmount = yFinal
    
    // Move back the sprite to its original position and let the flopw that called this function decides what to do
    spaceObject.XPos = xOriginal
    spaceObject.YPos = yOriginal
    SRS_DrawObjectToScreen(spaceObject, map)
ENDFUNCTION
