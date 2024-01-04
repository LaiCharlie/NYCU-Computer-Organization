#include <stdio.h>

void print_layer(int n, int l) {
    for (int j = 1; j < n-l; j++) {
        printf(" ");
    }
    for (int j = n-l; j <= n+l; j++) {
        printf("*");
    }
    printf("\n");
}

int main() {
    int op;
    printf("Please enter option (1: triangle, 2: inverted triangle): ");
    scanf("%d", &op);

    int n;
    printf("Please input a triangle size: ");
    scanf("%d", &n);

    for (int i = 0; i < n; i++) {
        if (op == 1) {
            print_layer(n, i);
        } else {
            print_layer(n, n-i-1);
        }
    }

    return 0;
}
