#include <iostream>
#include "tinymm8.hh"

driver::driver::driver(): trace_parsing(false), trace_scanning(false) {
	vars["one"] = 1;
	vars["two"] = 2;
}

int driver::driver::parse(const std::string &f) {
	file = f;
	loc.initialize(&file);
	scan_begin();
	yy::parser parse(*this);
	parse.set_debug_level(trace_parsing);
	res = parse();
	scan_end();
	return res;
}

int main(int argc, char** argv) {
	int res = 0;
	driver::driver drv;
	for (int i = 1; i < argc; ++i)
		if (argv[i] == std::string ("-p"))
			drv.trace_parsing = true;
		else if (argv[i] == std::string ("-s"))
			drv.trace_scanning = true;
		else if (!drv.parse (argv[i]))
			std::cout << drv.res << std::endl;
		else
			res = 1;
	return res;
}
