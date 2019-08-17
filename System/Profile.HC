U0 SetWallpaper(U8 *st = NULL)
{
  if(!st){
    st = "/Users/Default/DefaultWallpaper.png";
  }
  EContext2D *test_wp = LoadPNG(st);
  EWMSetWallpaper(test_wp);
  DelContext2D(test_wp);
}
