#include <stdio.h>

int prime(int n) {
	if (n == 1) {
		return 0;
	}

	for (int i = 2; i*i <= n; i++){
		if (n%i == 0) {
			return 0;
		}
	}
	return 1;
}

int main() {
	int n;
	printf("Please input a number: ");
	scanf("%d", &n);

	if (prime(n)) {
		printf("It's a prime\n");
	} else {
		printf("It's not a prime\n");
	}

	return 0;
}
