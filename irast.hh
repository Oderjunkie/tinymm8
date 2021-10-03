#pragma once
#include <string>
#include <map>

namespace irast {
        std::unordered_map<
            std::string,                                       //  functions
            std::unordered_map<std::string,                    //  variables
                               std::unordered_map<std::string, //  attributes
                                                  int>         // of variables
                               >>
            symbol_table;
        // class
} // namespace irast
