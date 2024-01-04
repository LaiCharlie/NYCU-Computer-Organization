#include <stdio.h>

int factorial(int n) {
	if (n == 1 || n == 0) {
		return 1;
	} else {
		return factorial(n-1) * n;
	}
}

int main() {
	int n;
	printf("Please input a number: ");
	scanf("%d", &n);
	printf("The result of factorial(n) is %d", factorial(n));
	return 0;
}