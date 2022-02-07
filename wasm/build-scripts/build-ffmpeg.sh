#!/bin/bash

set -eo pipefail
source $(dirname $0)/var.sh

mkdir -p wasm/packages/core/dist

#FLAGS=(
#  -I. -I./fftools -I$BUILD_DIR/include
#  -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavresample -Llibavutil -Lharfbuzz -Llibass -Lfribidi -Llibpostproc -Llibswscale -Llibswresample -L$BUILD_DIR/lib
#  -Wno-deprecated-declarations -Wno-pointer-sign -Wno-implicit-int-float-conversion -Wno-switch -Wno-parentheses -Qunused-arguments
#  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil -lpostproc -lm -lharfbuzz -lfribidi -lass -lx264 -lx265 -lvpx -lwavpack -lmp3lame -lfdk-aac -lvorbis -lvorbisenc -lvorbisfile -logg -ltheora -ltheoraenc -ltheoradec -lz -lfreetype -lopus -lwebp
#  fftools/ffmpeg_opt.c fftools/ffmpeg_filter.c fftools/ffmpeg_hw.c fftools/cmdutils.c fftools/ffmpeg.c
#  -s USE_SDL=2                                  # use SDL2
#  -s INVOKE_RUN=0                               # not to run the main() in the beginning
#  -s EXIT_RUNTIME=1                             # exit runtime after execution
#  -s MODULARIZE=1                               # use modularized version to be more flexible
#  -s EXPORT_NAME="createFFmpegCore"             # assign export name for browser
#  -s EXPORTED_FUNCTIONS="[_main]"  # export main and proxy_main funcs
#  -s EXPORTED_RUNTIME_METHODS="[FS, cwrap, ccall, setValue, writeAsciiToMemory]"   # export preamble funcs
#  -s INITIAL_MEMORY=2146435072                  # 64 KB * 1024 * 16 * 2047 = 2146435072 bytes ~= 2 GB
#  --pre-js wasm/src/pre.js
#  --post-js wasm/src/post.js
#  $OPTIM_FLAGS
#  ${EXTRA_FLAGS[@]}
#)

FLAGS=(
  -I. -I./fftools -I$BUILD_DIR/include
  -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavresample -Llibavutil -Llibass -Llibpostproc -Llibswscale -Llibswresample -L$BUILD_DIR/lib
  -Wno-deprecated-declarations -Wno-pointer-sign -Wno-implicit-int-float-conversion -Wno-switch -Wno-parentheses -Qunused-arguments
  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lavutil -lm -lwavpack -lmp3lame -lfdk-aac -lvorbis -lvorbisenc -lvorbisfile -logg -lopus -pthread
  fftools/ffmpeg_opt.c fftools/ffmpeg_filter.c fftools/ffmpeg_hw.c fftools/cmdutils.c fftools/ffmpeg.c
  -o wasm/packages/core/dist/ffmpeg-core.js
  -s USE_SDL=2                                  # use SDL2
  -s USE_PTHREADS=1                             # enable pthreads support
  -s PROXY_TO_PTHREAD=1                         # detach main() from browser/UI main thread
  -s INVOKE_RUN=0                               # not to run the main() in the beginning
  -s EXIT_RUNTIME=1                             # exit runtime after execution
  -s MODULARIZE=1                               # use modularized version to be more flexible
  -s EXPORT_NAME="createFFmpegCore"             # assign export name for browser
  -s EXPORTED_FUNCTIONS="[_main, _proxy_main]"  # export main and proxy_main funcs
  -s EXPORTED_RUNTIME_METHODS="[FS, cwrap, ccall, setValue, writeAsciiToMemory]"   # export preamble funcs
  -s INITIAL_MEMORY=2146435072                  # 64 KB * 1024 * 16 * 2047 = 2146435072 bytes ~= 2 GB
  -s ASSERTIONS=1 # for debug
  --pre-js wasm/src/pre.js
  --post-js wasm/src/post.js
  $OPTIM_FLAGS
)

echo "FFMPEG_EM_FLAGS=${FLAGS[@]}"
emmake make -j
emcc "${FLAGS[@]}"
