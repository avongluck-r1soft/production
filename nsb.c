#include <stdio.h>

int NumSetBits(int i); 
void printBits(size_t const size, void const * const ptr);

int main() {

	int i = 23456;
	printf("%d\n", NumSetBits(i));
	printBits(sizeof(i), &i);

	int j = 2147483647; 
	printf("%d\n", NumSetBits(j));
	printBits(sizeof(j), &j);
		
	return 0;
}

int NumSetBits(int i) {
	i=i-((i >> 1) & 0x55555555);
	i=(i & 0x33333333) + ((i >> 2) & 0x33333333);
	return (((i + (i >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24;
}
		

void printBits(size_t const size, void const * const ptr) {
	unsigned char *b = (unsigned char*) ptr;
	unsigned char byte;
	int i, j;

	for (i=size-1; i>=0; i--) {
		for (j=7; j>=0; j--) {
			byte = (b[i] >> j) & 1;
			printf("%u", byte);
		}
	}
	puts("");
}
