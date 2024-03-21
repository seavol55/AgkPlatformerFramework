/*
 * File name: CollisionSystem.agc
 *
 * Description: File that holds all the types and functions related to
 * collision detection in our game
 */
#include "src/System/SystemConventions.agc"


/*
 * Type name: CS_SpaceObject
 *
 * Properties:
 *     XPos        = actual x position of the space object in the screen (world coordinates)
 *     YPos        = actual y position of the space object in the screen (world coordinates)
 *     Width       = width of the sprite/object
 *     Height      = height of the sprite/object
 *     SpriteId    = Id of the sprite already loaded in memory for this object representation
 */
TYPE CS_SpaceObject
    XPos        AS FLOAT
    YPos        AS FLOAT
    SpriteId    AS INTEGER
ENDTYPE
