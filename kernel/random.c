static unsigned long seed = 123456789;

unsigned long
random(void)
{
  seed = seed * 1103515245 + 12345;
  return seed;
}