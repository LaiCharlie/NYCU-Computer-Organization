#include <stdio.h>

int main() {
    int op;
    printf("Please enter option (1: add, 2: sub, 3: mul): ");
    scanf("%d", &op);

    int a, b;
    printf("Please enter the first number: ");
    scanf("%d", &a);
    printf("Please enter the second number: ");
    scanf("%d", &b);

    int ans;
    if (op == 1) {
        ans = a + b;
    } else if (op == 2) {
        ans = a - b;
    } else if (op == 3) {
        ans = a * b;
    }
    printf("The calculation result is: %d", ans);

    return 0;
}
