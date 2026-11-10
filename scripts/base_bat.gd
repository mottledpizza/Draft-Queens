extends Node
class_name base_bat

#perfered bat:
#wood required by mlb, common ones being Maple, Ash, and Birch
var bat_material: String
#in ounces, averages 31-34 depending on height
var bat_weight: int
#in inches, averages 32 to 34
var bat_length: int
#in inches, maximum 2.61
var bat_diameter: float
# in inches, is the center of the zone of the bat, subtracted from the tip of the bat
var sweet_spot: int 
