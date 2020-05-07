#pragma once

///
/// @file    constexpr_sqrt.cpp
/// @brief   Calculate integer square roots at compile time using
///          C++11 constexpr.
/// @author  Kim Walisch, <kim.walisch@gmail.com>
/// @license Public Domain

#include <stdint.h>
#include <iostream>
#include <string>
#include <cmath>
#include <limits>

#define MID ((lo + hi + 1) / 2)

namespace utils
{
	constexpr inline uint64_t sqrt_helper(uint64_t x, uint64_t lo, uint64_t hi)
	{
		return lo == hi ? lo : ((x / MID < MID)
			? sqrt_helper(x, lo, MID - 1) : sqrt_helper(x, MID, hi));
	}

	constexpr inline uint64_t ct_sqrt(uint64_t x)
	{
		return sqrt_helper(x, 0, x / 2 + 1);
	}
}