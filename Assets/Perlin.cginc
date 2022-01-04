#ifndef PERLIN
#define PERLIN

#include "Assets/Noise.cginc"

float easeIn(float interpolator) {
    return interpolator * interpolator;
}

float easeOut(float interpolator) {
    return 1 - easeIn(1 - interpolator);
}

float easeInOut(float interpolator) {
    return lerp(easeIn(interpolator), easeOut(interpolator), interpolator);
}

float perlinFrom2D(float2 value) {
    
    //2d to 1d is a bit more complicated

    //generate random direction vectors at the corners of the cell
    float2 lowerLeftDirection = rand2dTo2d(float2(floor(value.x), floor(value.y))) * 2 - 1;
    float2 lowerRightDirection = rand2dTo2d(float2(ceil(value.x), floor(value.y))) * 2 - 1;
    float2 upperLeftDirection = rand2dTo2d(float2(floor(value.x), ceil(value.y))) * 2 - 1;
    float2 upperRightDirection = rand2dTo2d(float2(ceil(value.x), ceil(value.y))) * 2 - 1;
    
    float2 fraction = frac(value);

    float lowerLeftValue = dot(lowerLeftDirection, fraction - float2(0, 0));
    float lowerRightValue = dot(lowerRightDirection, fraction - float2(1, 0));
    float upperLeftValue = dot(upperLeftDirection, fraction - float2(0, 1));
    float upperRightValue = dot(upperRightDirection, fraction - float2(1, 1));

    float interpolatorX = easeInOut(fraction.x);
    float interpolatorY = easeInOut(fraction.y);

    // interpolate horizontally connected cells
    float lowerCells = lerp(lowerLeftValue, lowerRightValue, interpolatorX);
    float upperCells = lerp(upperLeftValue, upperRightValue, interpolatorX);

    //interpolate vertically
    float noise = lerp(lowerCells, upperCells, interpolatorY);

    return noise;
}

float perlinFrom3D(float3 value) {
    float3 fraction = frac(value);
    float interpolatorX = easeInOut(frac(value.x));
    float interpolatorY = easeInOut(frac(value.y));
    float interpolatorZ = easeInOut(frac(value.z));
    
    //get noise at z value
    float cellNoiseZ[2];
    [unroll]
    for (int z=0; z<=1; z++) {
        
        float cellNoiseY[2];
        //get noise at y value
        [unroll]
        for (int y=0; y<=1; y++){
            
            float cellNoiseX[2];
            //get noise at x value
            [unroll]
            for(int x=0; x<=1; x++) {
                float3 cell = floor(value) + float3(x, y, z);

                //compute gradient at this cell
                float3 cellGradient = rand3dTo3d(cell) * 2 - 1;

                //create a vector that is 0,0,0 at this cell's origin
                float3 compareVector = fraction - float3(x, y, z);

                //get x-coordinate noise
                cellNoiseX[x] = dot(cellGradient, compareVector);
            }

            //collapse x-coordinate
            cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
        }
        
        //collapse y-coordinate
        cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
    }

    //collapse z-coordinate
    float noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
    return noise;
}
#endif