#!/bin/sh
# Compila zlib + lcms2 + librevenge + libcdr (fork) + cdrjs para JavaScript puro (sem WebAssembly,
# porque o visualizador de artefatos bloqueia wasm). Saída: apps/editor/public/cdrjs.js (carregado sob demanda, fora do HTML)
# Requer: Emscripten (o CI usa o 3.1.6), fontes em $DEPS (zlib-1.3.dfsg e librevenge-0.0.5 dos pacotes do noble e
# o LittleCMS 2.16 em lcms2, pinados em .github/workflows/importador.yml; ZL/RV/LC trocam os caminhos) e o config.h
# do ./configure do libcdr. Regenerar pelo CI: README, "Compilar o importador".
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
DEPS=${DEPS:-/root/wasmdeps}
OBJ=${OBJ:-/tmp/cdrjs-obj}
OPT=${OPT:--O2}
mkdir -p "$OBJ"/z "$OBJ"/lcms "$OBJ"/rv "$OBJ"/cdr
ZL=${ZL:-$DEPS/zlib-1.3.dfsg}; LC=${LC:-$DEPS/lcms2}; RV=${RV:-$DEPS/librevenge-0.0.5}; CDR=${CDR:-$HERE/../..}
mkdir -p "$OBJ"/boost && [ -e "$OBJ"/boost/boost ] || ln -s /usr/include/boost "$OBJ"/boost/boost
cc() { out=$1; shift; [ "$out" -nt "$1" ] && return 0; "$@" -o "$out"; }
for f in adler32 crc32 deflate inflate inftrees inffast trees zutil uncompr compress; do
  cc "$OBJ/z/$f.o" emcc $OPT -c "$ZL/$f.c" -I"$ZL" &
done; wait
for f in "$LC"/src/*.c; do b=$(basename "$f" .c); cc "$OBJ/lcms/$b.o" emcc $OPT -c "$f" -I"$LC/include" & done; wait
CXXF="$OPT -std=c++17 -fexceptions -DNDEBUG -DBOOST_ALL_NO_LIB -DBOOST_NO_CXX98_FUNCTION_BASE -I$OBJ/boost -I$ZL"
for f in RVNGBinaryData RVNGProperty RVNGPropertyList RVNGPropertyListVector RVNGString RVNGStringVector RVNGMemoryStream RVNGStreamImplementation RVNGOLEStream RVNGZipStream RVNGDirectoryStream RVNGSVGDrawingGenerator; do
  cc "$OBJ/rv/$f.o" em++ $CXXF -c "$RV/src/lib/$f.cpp" -I"$RV/inc" -I"$RV/src/lib" &
done; wait
for f in "$CDR"/src/lib/*.cpp; do b=$(basename "$f" .cpp)
  cc "$OBJ/cdr/$b.o" em++ $CXXF -c "$f" -I"$CDR" -I"$CDR/inc" -I"$CDR/src/lib" -I"$RV/inc" -I"$LC/include" -I"$HERE/icushim" -DHAVE_CONFIG_H -DLIBCDR_BUILD &
done; wait
em++ $CXXF -c "$HERE/cdrjs.cpp" -I"$CDR/inc" -I"$RV/inc" -o "$OBJ/cdrjs.o"
mkdir -p "$HERE/../../apps/editor/public"
em++ $OPT -fexceptions "$OBJ"/cdrjs.o "$OBJ"/cdr/*.o "$OBJ"/rv/*.o "$OBJ"/lcms/*.o "$OBJ"/z/*.o \
  -sWASM=0 -sMODULARIZE=1 -sEXPORT_ES6=1 -sEXPORT_NAME=createCdrModule -sALLOW_MEMORY_GROWTH=1 -sENVIRONMENT=web,worker,node \
  -sEXPORTED_FUNCTIONS=_cdr_parse,_cdr_result,_cdr_free,_cdr_zip_entry,_cdr_zip_read,_cdr_zip_list,_cdr_release,_malloc,_free -sEXPORTED_RUNTIME_METHODS=UTF8ToString,HEAPU8 \
  -sDISABLE_EXCEPTION_CATCHING=0 -sINITIAL_MEMORY=67108864 -sDYNAMIC_EXECUTION=0 --memory-init-file 0 \
  -o "$HERE/../../apps/editor/public/cdrjs.js"
ls -la "$HERE/../../apps/editor/public/cdrjs.js"
