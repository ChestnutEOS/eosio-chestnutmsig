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