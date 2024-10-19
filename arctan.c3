module arctan;

import std::math;
import std::io;

// Define a 2D vector type
def Vec2 = short[<2>];

// Lookup table for arctangent values (multiplied by 100 for precision)
const int[256] ATAN_TABLE = {
    0, 0, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 6, 
    6, 7, 7, 7, 8, 8, 9, 9, 9, 10, 10, 11, 11, 11, 12, 12, 
    12, 13, 13, 14, 14, 14, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 
    19, 19, 19, 20, 20, 20, 21, 21, 22, 22, 22, 23, 23, 23, 24, 24, 
    25, 25, 25, 26, 26, 26, 27, 27, 28, 28, 28, 29, 29, 29, 30, 30, 
    30, 31, 31, 31, 32, 32, 33, 33, 33, 34, 34, 34, 35, 35, 35, 36, 
    36, 36, 37, 37, 37, 38, 38, 38, 39, 39, 39, 40, 40, 40, 41, 41, 
    41, 42, 42, 42, 43, 43, 43, 44, 44, 44, 45, 45, 45, 46, 46, 46, 
    47, 47, 47, 47, 48, 48, 48, 49, 49, 49, 50, 50, 50, 51, 51, 51, 
    51, 52, 52, 52, 53, 53, 53, 53, 54, 54, 54, 55, 55, 55, 55, 56, 
    56, 56, 57, 57, 57, 57, 58, 58, 58, 59, 59, 59, 59, 60, 60, 60, 
    60, 61, 61, 61, 61, 62, 62, 62, 63, 63, 63, 63, 64, 64, 64, 64, 
    65, 65, 65, 65, 66, 66, 66, 66, 67, 67, 67, 67, 67, 68, 68, 68, 
    68, 69, 69, 69, 69, 70, 70, 70, 70, 71, 71, 71, 71, 71, 72, 72, 
    72, 72, 73, 73, 73, 73, 73, 74, 74, 74, 74, 74, 75, 75, 75, 75, 
    76, 76, 76, 76, 76, 77, 77, 77, 77, 77, 78, 78, 78, 78, 78, 79
};

// Function to calculate integer square root
fn int int_sqrt(int x)
{
    int r = 0;
    int t, b;

    for (b = 0x40000000; b != 0; b >>= 2)
    {
        t = r + b;
        r >>= 1;
        if (x >= t)
        {
            x -= t;
            r += b;
        }
    }
    return r;
}

// Function to calculate arctangent using integer lookup table
fn int atan2_int(int y, int x)
{
    if (x == 0 && y == 0) return 0;

    int ax = math::abs(x);
    int ay = math::abs(y);
    int angle;

    if (ax >= ay)
    {
        if (ax == 0) return (y >= 0) ? 157 : -157;
        int atan_index = (int)((long)ay * 256 / ax);
        if (atan_index >= 256) atan_index = 255;  // Prevent overflow
        angle = ATAN_TABLE[atan_index];
    }
    else
    {
        int atan_index = (int)((long)ax * 256 / ay);
        if (atan_index >= 256) atan_index = 255;  // Prevent overflow
        angle = 157 - ATAN_TABLE[atan_index];
    }

    if (x < 0) angle = 314 - angle;
    if (y < 0) angle = -angle;

    return (angle + 314) % 628 - 314;  // Keep within range [-314, 314]
}

// Function to calculate the angle between two Vec2
fn int angle_between(Vec2 p1, Vec2 p2)
{
    return atan2_int(p2.y, p2.x) - atan2_int(p1.y, p1.x);
    // // Calculate dot product
    // int dot_product = p1.x * p2.x + p1.y * p2.y;
    // 
    // // Calculate squared magnitudes
    // int mag1_squared = p1.x * p1.x + p1.y * p1.y;
    // int mag2_squared = p2.x * p2.x + p2.y * p2.y;
    // 
    // // Calculate magnitudes
    // int mag1 = int_sqrt(mag1_squared);
    // int mag2 = int_sqrt(mag2_squared);
    // 
    // // Calculate cross product to determine direction
    // int cross_product = p1.x * p2.y - p1.y * p2.x;

    // // Use atan2 to get the angle
    // return atan2_int(cross_product, dot_product);
}

/**
 * @require hundredths_radians > -314, hundredths_radians < 314, "radians out of bounds"
 **/
fn int rad_to_deg(int hundredths_radians)
{
    // Convert hundredths of radians to degrees
    int degrees = (hundredths_radians * 180) / 314;

    // Map to the range [0, 359] using modulo
    degrees = degrees % 360;
    
    // Handle negative values (to ensure they are positive in the range [0, 359])
    if (degrees < 0) degrees += 360;

    return degrees;
}

/**
 * Fast approximate distance
 * https://www.flipcode.com/archives/Fast_Approximate_Distance_Functions.shtml
 **/
fn ushort distance(Vec2 v)
{
   ushort min, max;
   ushort x = (ushort) math::abs(v.x);
   ushort y = (ushort) math::abs(v.y);

   if ( x < y )
   {
      min = x;
      max = y;
   } else {
      min = y;
      max = x;
   }

   return ((( max << 8 ) + ( max << 3 ) - ( max << 4 ) - ( max << 1 ) +
            ( min << 7 ) - ( min << 5 ) + ( min << 3 ) - ( min << 1 )) >> 8 );
}
