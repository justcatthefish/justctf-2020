#include "tao/pegtl.hpp"
using DIGIT = tao::pegtl::digit;
#include "grammar.hpp"

#include <iostream>

int main(int argc, char **argv) {
   if(argc != 2) {
    std::cout << "No flag? Too much flags?" << std::endl;
    return 1;
   }

   tao::pegtl::argv_input in( argv, 1 );
   tao::pegtl::parse< tao::pegtl::must<flag> >( in ) ;
   std::cout << "Ok?" << std::endl;
}

