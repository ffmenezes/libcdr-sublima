#pragma once
#include "utypes.h"
// Detecção automática de charset desligada: o libcdr cai no padrão (windows-1252), que é o do português.
struct UCharsetDetector; struct UCharsetMatch;
static inline UCharsetDetector *ucsdet_open(UErrorCode *s) { *s = U_UNSUPPORTED_ERROR; return nullptr; }
static inline void ucsdet_close(UCharsetDetector *) {}
static inline bool ucsdet_enableInputFilter(UCharsetDetector *, bool) { return false; }
static inline void ucsdet_setText(UCharsetDetector *, const char *, int32_t, UErrorCode *s) { *s = U_UNSUPPORTED_ERROR; }
static inline const UCharsetMatch *ucsdet_detect(UCharsetDetector *, UErrorCode *s) { *s = U_UNSUPPORTED_ERROR; return nullptr; }
static inline const char *ucsdet_getName(const UCharsetMatch *, UErrorCode *s) { *s = U_UNSUPPORTED_ERROR; return nullptr; }
static inline int32_t ucsdet_getConfidence(const UCharsetMatch *, UErrorCode *s) { *s = U_UNSUPPORTED_ERROR; return 0; }
