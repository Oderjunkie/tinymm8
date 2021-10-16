u8 fib(u8 i) {
	if (i <= 1) return 1;
	return fib(i - 1) + fib(i - 2);
}

main() {
    *0x8000 = fib(90);
}
