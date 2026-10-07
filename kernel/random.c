static unsigned long seed = 666;

unsigned long
random(void)
{
  seed = seed * 1103515245 + 12345;
  return seed;
}