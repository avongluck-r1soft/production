#include <stdio.h>
#include <stdint.h>
#include <math.h>

int main() {

    uint32_t i = pow(2, 32);
    printf("%lu\n", i);

    i++;
    printf("%lu\n", i);

    return 0;
}
    
