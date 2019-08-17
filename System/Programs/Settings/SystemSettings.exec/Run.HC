// Erythros System Settings
U64 flags;
ETask *my_task=EWMGetTask(Fs);
my_task->title = "SystemSettings";
my_task->icon = LoadPNG("/System/Media/Themes/Default/Icons/16/cog.png");

U8 *rom_filename=NULL;
Bool rom_select=FALSE;

CTask *wallpaper_task=NULL;

CDirEntry *png_de;

U8 *my_fn=CAlloc(1024);

my_task->menu->selected=-1;
my_task->menu->size = 1;
my_task->menu->items=CAlloc(sizeof(U64)*my_task->menu->size);
my_task->menu->items[0]=CAlloc(sizeof(EMenuItem));

my_task->menu->items[0]->id = 1; my_task->menu->items[0]->text = "Settings";

EContextMenu *open_ctx_menu = EWMNewContextMenu;
open_ctx_menu->task=my_task;
open_ctx_menu->width=96;
EWMAddContextMenuItem(open_ctx_menu, 101, "PNG Image Files (*.png)",, WMGR_OPEN_SEL_CB, ".png");
EWMAddContextMenuItem(open_ctx_menu, 102, "All Files (*.*)",, WMGR_OPEN_SEL_CB);

EContextMenu *file_menu = EWMNewContextMenu;
file_menu->task=my_task;
file_menu->width=96;
EWMAddContextMenuItem(file_menu, 1, "Change Wallpaper",, WMGR_CMD_TASK_CB);
EWMAddContextMenuHorizRule(file_menu);
EWMAddContextMenuItem(file_menu, 2, "Exit",, WMGR_CMD_TASK_CB);
my_task->menu->items[0]->menu = file_menu;

my_task->fp_mask=".png";

flags = (EWIN_HAS_ICON | EWIN_HAS_TITLE | EWIN_HAS_MINBTN);
EWindow *my_win = EWMNewWindow(2, 2, 256+8, 240+28, CAlloc(1024), flags);
// my_win->resizable = TRUE;
my_win->icon = my_task->icon;
StrPrint(my_win->title, "System Settings");
EWMAddWindow(my_task, my_win);

EWindow *my_open_dlg=NULL;

#include "::/System/Profile.HC";
I64 ChangeWallpaper(U8 *png_file)
{
  // Copy(png_file, "C:/Users/Default/DefaultWallpaper.png");
	SetWallpaper(png_file);
	return 0;
}

EWMCenterWindow(my_win);
EWMShow(my_win);

Cd("::/System/Media/Wallpapers");
wmgr->loading=FALSE;
while (1)
{

	switch (my_task->menu_cb)
	{
		case 1:
		    my_task->menu_cb=0;
		    if (!my_open_dlg)
		    {
		        my_open_dlg = EWMOpenDialog(my_task, "Select Wallpaper", "PNG Image Files (*.png)|*.png|All Files (*.*)|*.*");
		        EWMSetOFSFileOptions(my_open_dlg, open_ctx_menu);
		        my_task->fp_mask=".png";
		    }
		    break;
    case 2:
        my_task->menu_cb=0;
        my_win->msg_close=TRUE;
        break;
    default:
        break;
	}

	if (my_open_dlg && (my_open_dlg->msg_close ||
        my_open_dlg->widgets->next->next->clicked))
	{
        my_open_dlg->widgets->next->next->clicked=FALSE;
        EWMDelWindow(my_open_dlg);
        EWMSetActiveWindow(my_win);
        my_open_dlg = NULL;
  }

	if (my_open_dlg && (my_open_dlg->widgets->next->clicked))
	{
	    my_open_dlg->widgets->next->clicked=FALSE;
	    png_de=FilesFind(EWMGetOFSTextTarget(my_open_dlg));
	    if (png_de)
	    {
	        if (png_de->attr & RS_ATTR_DIR == RS_ATTR_DIR)
	        {
	            Cd(EWMGetOFSTextTarget(my_open_dlg));
	       	    StrPrint(ofs_dirsel, "*:%s|1", Fs->cur_dir);
	            ofs_dirsel[0]=Fs->cur_dv->drv_let;
	            EWMUpdateOFSDirTree(my_open_dlg, ofs_dirsel);
	            StrPrint(EWMGetOFSTextTarget(my_open_dlg),"");
	        }
	        else
	        {
	            my_open_dlg->widgets->next->clicked=FALSE;
	            StrPrint(my_fn, "%s/%s",DirCur, EWMGetOFSTextTarget(my_open_dlg));
	            EWMDelWindow(my_open_dlg);
	            EWMSetActiveWindow(my_win);
	            my_open_dlg = NULL;
	            wallpaper_task = Spawn(&ChangeWallpaper, my_fn,,2);
	            wmgr->loading=FALSE;

	        }
	    }
	    DirTreeDel(png_de);
	}

	if (my_win && my_win->msg_close)
	{
		EWMDelWindow(my_win);
    EWMDelTask(my_task);
    my_win = NULL;
		Exit;
	}
  Sleep(1);
}
