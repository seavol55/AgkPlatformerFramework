/*
 * File name: CollisionSystem.agc
 *
 * Description: File that holds all the types and functions related to
 * collision detection in our game
 */
#include "src/System/SystemConventions.agc"

/*
 * Type Name: CS_CollisionBoundary
 *
 * Properties:
 *     XMin = Min X coordinate where the collision boundary starts regarding the world coordinates
 *     XMax = Max X coordinate where the collision boundary ends regarding the world coordinates
 *     YMin = Min Y coordinate where the collision boundary starts regarding the world coordinates
 *     YMax = Max Y coordinate where the collision boundary ends regarding te world coordinates
 */
TYPE CS_CollisionBoundary
    XMin    AS INTEGER
    XMax    AS INTEGER 
    YMin    AS INTEGER
    YMax    AS INTEGER
ENDTYPE


/*
 * Type Name: CS_BoxCollider
 *
 * Properties:
 *     XOffset = starting x position where the box starts (based on sprite position)
 *     YOffset = starting y position where the box starts (based on sprite position)
 *     Width   = width of the box that represents the collision
 *     Height  = height of the box that represents the collision
 *
 * Description: Struct that represents a box that is considered that anything that overlaps
 *              with the box, is a collision
 */
TYPE CS_BoxCollider
    XOffset AS FLOAT
    YOffset AS FLOAT
    Width   AS INTEGER
    Height  AS INTEGER
ENDTYPE



/*
 * Type name: CS_SpaceObject
 *
 * Properties:
 *     XPos        = actual x position of the space object in the screen
 *     YPos        = actual y position of the space object in the screen
 *     Width       = width of the sprite/object
 *     Height      = height of the sprite/object
 *     BoxCollider = Box collider object to be used to represent collision boundaries for
 *                   the space object
 */
TYPE CS_SpaceObject
    XPos        AS FLOAT
    YPos        AS FLOAT
    BoxCollider AS CS_BoxCollider
ENDTYPE


/*
 * Function Name: CS_AreObjectsColliding
 * 
 * Parameters
 *     a = CS_SpaceObject representing the first object to compare collision
 *     b = CS_SpaceObject representing the second object to compare collision
 *
 * Return Values:
 *     Boolean (TRUE or FALSE)
 *
 * Description: Function that takes 2 objects and compares if both objects are
 *              colliding somehow
 */
FUNCTION CS_AreObjectsColliding(a REF AS CS_SpaceObject, b REF AS CS_SpaceObject)
    aBoundaries AS CS_CollisionBoundary
    bBoundaries AS CS_CollisionBoundary
    result      AS INTEGER
    
    aBoundaries = CS_GetCollisionBoundaries(a)
    bBoundaries = CS_GetCollisionBoundaries(b)
    result      = FALSE
    
    // Check if world coordinates for each box collider that represents the objects in
    // the world are overlapping
    
    // Check first B against A
    IF (bBoundaries.XMin >= aBoundaries.XMin AND bBoundaries.XMin <= aBoundaries.XMax)
        result = TRUE
    ELSEIF (bBoundaries.XMax >= aBoundaries.XMin AND bBoundaries.XMax <= aBoundaries.XMax)
        result = TRUE
    ENDIF
    
    IF (bBoundaries.YMin >= aBoundaries.YMin AND bBoundaries.YMin <= aBoundaries.YMax)
        result = TRUE
    ELSEIF (bBoundaries.YMax >= aBoundaries.YMin AND bBoundaries.YMax <= aBoundaries.YMax)
        result = TRUE
    ENDIF
    
    
    // Check A against B
    IF (aBoundaries.XMin >= bBoundaries.XMin AND aBoundaries.XMin <= bBoundaries.XMax)
        result = TRUE
    ELSEIF (aBoundaries.XMax >= bBoundaries.XMin AND aBoundaries.XMax <= bBoundaries.XMax)
        result = TRUE
    ENDIF
    
    IF (aBoundaries.YMin >= bBoundaries.YMin AND aBoundaries.YMin <= bBoundaries.YMax)
        result = TRUE
    ELSEIF (aBoundaries.YMax >= bBoundaries.YMin AND aBoundaries.YMax <= bBoundaries.YMax)
        result = TRUE
    ENDIF
ENDFUNCTION result


/*
 * Function Name: CS_GetCollisionBoundaries
 *
 * Parameters:
 *     spaceObject = Object representatiomn on screen taht we want to calculate collision
 *                   boundaries regarding world coordinates
 *
 * Return Values:
 *     CS_CollisionBoundary
 *
 * Description: Function that takes a SpaceObject and calculates the collision coordinates
 *              regarding the world position
 */
FUNCTION CS_GetCollisionBoundaries(spaceObject REF AS CS_SpaceObject)
    result AS CS_CollisionBoundary
    
    // Calculate max/min boundaries for X
    result.XMin = spaceObject.XPos + spaceObject.BoxCollider.XOffset
    result.XMax = result.XMin + spaceObject.BoxCollider.Width
    
    // Calculate max/min boundaries for Y
    result.YMin = spaceObject.YPos + spaceObject.BoxCollider.YOffset
    result.YMax = result.YMin + spaceObject.BoxCollider.Height
ENDFUNCTION result
