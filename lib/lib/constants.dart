const logicalWidth = 31;
const logicalHeight = 15;

const TICK_INTERVAL = 100.0; //ms

const BASE_SPEED = 5.0;

const sourceIdWall1 = "wall1";
const sourceIdWall2 = "wall2";
const sourceIdMonster1 = "monster1";
const sourceIdHero1 = "hero1";
const sourceIdBomb1 = "bomb1";
const sourceIdExplosion1 = "explosion1";
const sourceIdDestory1 = "destory1";
const sourceIdDestory2 = "destory2";
const sourceIdTreasure1 = "treasure1";
const sourceIdGate1 = "gate1";

const int keyLeft = 0;
const int keyUp = 1;
const int keyRight = 2;
const int keyDown = 3;
const int keyA = 4;
const int keyB = 5;

const String eventDamage = "damage";
const String eventOnDestroy = "onDestroy";
const String eventAnimEnd = "AnimEnd";
const String eventLevelComplte = "levelComplte";

const int stateInit = -1;
const int stateNormal = 0;
const int stateDestroying = 1;
const int stateDestroyed = 2;

