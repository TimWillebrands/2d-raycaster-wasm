fn Color hsv2rgb(char h, char s, char v) {
    Color color;
    
    if (s == 0) {
        // If saturation is 0, the color is grayscale
        color.r = color.g = color.b = v;
        return color;
    }
    
    // Sector 0 to 5
    char sector = h / 43;
    // Fraction within sector
    char remainder = (h - (sector * 43)) * 6;
    
    char p = (v * (255 - s)) >> 8;
    char q = (v * (255 - ((s * remainder) >> 8))) >> 8;
    char t = (v * (255 - ((s * (255 - remainder)) >> 8))) >> 8;
    
    switch (sector) {
        case 0:  color.r = v; color.g = t; color.b = p; break;
        case 1:  color.r = q; color.g = v; color.b = p; break;
        case 2:  color.r = p; color.g = v; color.b = t; break;
        case 3:  color.r = p; color.g = q; color.b = v; break;
        case 4:  color.r = t; color.g = p; color.b = v; break;
        default: color.r = v; color.g = p; color.b = q; break;
    }
    
    return color;
}
