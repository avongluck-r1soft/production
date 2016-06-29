#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    long ps;
    ps = sysconf(_SC_PAGESIZE);
    printf("page size in bytes: %ld\n", ps);
    return 0;
}

