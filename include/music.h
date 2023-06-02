#ifndef _MUSIC
#define _MUSIC

#define TITLE_MUSIC     0
#define GAME_OVER_MUSIC 1
#define BOSS_MUSIC      2
#define LEVEL1_MUSIC    3
#define LEVEL2_MUSIC    4
#define LEVEL3_MUSIC    5
#define END_MUSIC       6

void init_sound(void) BANKED;
void set_music(UBYTE song) BANKED;
void play_music(void) BANKED;
void stop_music(void) BANKED;
void restart_music(void) BANKED;

#endif