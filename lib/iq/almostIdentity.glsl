// From Inigo Quilez
// http://iquilezles.org/www/articles/functions/functions.htm
//
// Only changes x if it gets below threshold, to avoid tiny numbers.
// Returns zeroValue for x = 0.
float almostIdentity(in float x, in float threshold, in float zeroValue) {
    if (x > threshold) { return x; }

    float a = 2.0*zeroValue - threshold;
    float b = 2.0*threshold - 3.0*zeroValue;
    float t = x / threshold;

    return (a*t + b) * t * t + zeroValue;
}

#pragma glslify: export(almostIdentity);
