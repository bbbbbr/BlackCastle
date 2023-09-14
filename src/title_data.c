#pragma bank 255

#include "global.h"
#include "data.h"

#include <gbdk/incbin.h>

#ifndef MEGADUCK32K
    INCBIN(title_tiles, "res/title_bg.chr")
    INCBIN_EXTERN(title_tiles)

    INCBIN(title_map, "res/title_map.bin")
    INCBIN_EXTERN(title_map)

    INCBIN(font_tiles, "res/font_tiles.chr")
    INCBIN_EXTERN(font_tiles)
#else
    INCBIN(title_tiles, "res/title_bg.chr.gbcomp")
    INCBIN_EXTERN(title_tiles)

    INCBIN(title_map, "res/title_map.bin.gbcomp")
    INCBIN_EXTERN(title_map)

    INCBIN(font_tiles, "res/font_tiles.chr.gbcomp")
    INCBIN_EXTERN(font_tiles)
#endif // #ifndef MEGADUCK32K