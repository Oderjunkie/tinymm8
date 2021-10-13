#include "tinymm8.hh"
#include <iostream>

bool driver::pipe_mode;

driver::driver::driver() : trace_scanning(false), trace_parsing(false) {
        vars["one"] = 1;
        vars["two"] = 2;
}

int driver::driver::parse(const std::string& f) {
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
        std::cout << "\e[m";
        for (int i = 1; i < argc; ++i)
                if (argv[i] == std::string("-d"))
                        drv.trace_parsing = true;
                else if (argv[i] == std::string("-s"))
                        drv.trace_scanning = true;
                else if (argv[i] == std::string("-p"))
                        driver::pipe_mode = true;
                else if (argv[i] == std::string("-h")) {
                        std::cout << "USAGE" << std::endl
                                  << "-----" << std::endl
                                  << "-d           Trace the parser." << std::endl
                                  << "-s           Trace the scan." << std::endl
                                  << "-p           Pipe mode. (write to stdout)" << std::endl
                                  << "-h           Display this message." << std::endl
                                  << std::endl;
                        return 0;
                } else if (drv.parse(argv[i]) != 0)
                        std::cout << drv.res << std::endl;
                else
                        res = 1;
        return res;
}
