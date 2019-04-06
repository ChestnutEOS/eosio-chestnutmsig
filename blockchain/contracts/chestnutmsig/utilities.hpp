#pragma once

#include <eosiolib/asset.hpp>
#include <eosiolib/eosio.hpp>

std::string symbol_to_string( symbol sym ) {
    uint64_t v = sym.raw();
    v >>= 8;
    string result;
    while (v > 0) {
            char c = static_cast<char>(v & 0xFF);
            result += c;
            v >>= 8;
    }
    return result;
}

static const char* charmap = "0123456789";


std::string uint128ToString(const uint128_t& value)
{
    std::string result;
    result.reserve( 40 ); // max. 40 digits possible ( uint64_t has 20) 
    uint128_t helper = value;

    do {
        result += charmap[ helper % 10 ];
        helper /= 10;
    } while ( helper );
    std::reverse( result.begin(), result.end() );
    return result;
}
