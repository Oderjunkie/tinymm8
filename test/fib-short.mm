u8 fib(u8 i)
    i <= 1 ? 1 :
    fib(i - 1) + fib(i - 2);

main() {
    *0x8000 = fib(90);
}