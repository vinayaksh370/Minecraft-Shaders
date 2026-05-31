#include <iostream>

int add(int a, int b){
    int c = a + b;
    return c;
}
int sub(int a, int b){
    int c = a - b;
    return c;
}
int mul(int a, int b){
    int c = a * b;
    return c;
}

int main()
{
    std::cout << "Print me daddy";
    std::cout << add(2,5);
    std::cout << "Print me mommy"
    std::cout << sub(2,5);
    std::cout << mul(2,5);
}
