#pragma once
#include "parser.hh"
#include <unordered_map>
#include <string>

namespace driver {
	class driver {
		public:
			driver();
			std::unordered_map<std::string, int> vars;
			int parse(const std::string& f);
			bool trace_scanning;
			bool trace_parsing;
			void scan_begin();
			void scan_end();
			yy::location loc;
			int res;
		protected:
			std::string file;
	};
}

#define YY_DECL yy::parser::symbol_type yylex (driver::driver& drv)
YY_DECL;
