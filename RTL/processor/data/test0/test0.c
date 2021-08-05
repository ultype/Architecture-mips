#include <stdio.h>

int test(int num);

int main(void) {
  int num1 = 3, num2 = 4, num=0;
  num = num1 + num2;
  return 0;
}


int test(int num) {
    int a = 0;
    if(num >= 0) a = a+3;
    else a = a+2;
    return a;
}
