u8 fib(u8 i) {
	if (i <= 1)
		return 1;
	else
		return fib(i - 1) + fib(i - 2);
}

void main() {
    *0x8000 = fib(90);
}
