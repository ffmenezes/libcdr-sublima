// Substituto mínimo do ICU para compilar o libcdr no navegador (Sublima).
// Só o que o libcdr_utils.cpp usa: detecção de charset (desligada) e conversão de UTF-16LE / windows-125x.
#pragma once
#include <cstdint>
#include <cstring>
typedef int32_t UChar32;
typedef int UErrorCode;
#define U_ZERO_ERROR 0
#define U_UNSUPPORTED_ERROR 16
#define U_INVALID_CHAR_FOUND 10
#define U_INDEX_OUTOFBOUNDS_ERROR 8
#define U_FAILURE(x) ((x) > U_ZERO_ERROR)
#define U_SUCCESS(x) ((x) <= U_ZERO_ERROR)
#define U_IS_UNICODE_CHAR(c) ((uint32_t)(c) < 0xd800 || (0xdfff < (uint32_t)(c) && (uint32_t)(c) <= 0x10ffff && ((c) & 0xfffe) != 0xfffe && !((uint32_t)(c) >= 0xfdd0 && (uint32_t)(c) <= 0xfdef)))
