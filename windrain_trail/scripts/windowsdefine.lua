--ShowWindow() Commands
SW_HIDE             =0
SW_SHOWNORMAL       =1
SW_NORMAL           =1
SW_SHOWMINIMIZED    =2
SW_SHOWMAXIMIZED    =3
SW_MAXIMIZE         =3
SW_SHOWNOACTIVATE   =4
SW_SHOW             =5
SW_MINIMIZE         =6
SW_SHOWMINNOACTIVE  =7
SW_SHOWNA           =8
SW_RESTORE          =9
SW_SHOWDEFAULT      =10
SW_FORCEMINIMIZE    =11
SW_MAX              =11



--WM_SIZE message wParam values
SIZE_RESTORED       =0
SIZE_MINIMIZED      =1
SIZE_MAXIMIZED      =2
SIZE_MAXSHOW        =3
SIZE_MAXHIDE        =4


--- MessageBox() flags ---

-- button flags
MB_OK                       = toDWORD('00000000')
MB_OKCANCEL                 = toDWORD('00000001')
MB_ABORTRETRYIGNORE         = toDWORD('00000002')
MB_YESNOCANCEL              = toDWORD('00000003')
MB_YESNO                    = toDWORD('00000004')
MB_RETRYCANCEL              = toDWORD('00000005')

-- icon flags
MB_ICONHAND                 = toDWORD('00000010')
MB_ICONQUESTION             = toDWORD('00000020')
MB_ICONEXCLAMATION          = toDWORD('00000030')
MB_ICONASTERISK             = toDWORD('00000040')
MB_ICONWARNING              =MB_ICONEXCLAMATION
MB_ICONERROR                =MB_ICONHAND
MB_ICONINFORMATION          =MB_ICONASTERISK
MB_ICONSTOP					=MB_ICONHAND

-- default button flags
MB_DEFBUTTON1               = toDWORD('00000000')
MB_DEFBUTTON2               = toDWORD('00000100')
MB_DEFBUTTON3               = toDWORD('00000200')
MB_DEFBUTTON4               = toDWORD('00000300')

-- addition flags
MB_NOFOCUS                  = toDWORD('00008000')
MB_SETFOREGROUND            = toDWORD('00010000')
MB_DEFAULT_DESKTOP_ONLY     = toDWORD('00020000')
MB_TOPMOST                  = toDWORD('00040000')
MB_RIGHT                    = toDWORD('00080000')
MB_RTLREADING               = toDWORD('00100000')



--- Dialog Box Command IDs
IDOK                =1
IDCANCEL            =2
IDABORT             =3
IDRETRY             =4
IDIGNORE            =5
IDYES               =6
IDNO                =7
IDCLOSE				=8
IDHELP				=9


--- Choose Color Dialog flags ---
CC_RGBINIT               = toDWORD('00000001')
CC_FULLOPEN              = toDWORD('00000002')
CC_PREVENTFULLOPEN       = toDWORD('00000004')
--CC_SHOWHELP              = toDWORD('00000008')
--CC_ENABLEHOOK            = toDWORD('00000010')
--CC_ENABLETEMPLATE        = toDWORD('00000020')
--CC_ENABLETEMPLATEHANDLE  = toDWORD('00000040')
CC_SOLIDCOLOR            = toDWORD('00000080')
CC_ANYCOLOR              = toDWORD('00000100')


--- Choose File Dialog flags ---
OFN_READONLY                 = toDWORD('00000001')
OFN_OVERWRITEPROMPT          = toDWORD('00000002')
OFN_HIDEREADONLY             = toDWORD('00000004')
OFN_NOCHANGEDIR              = toDWORD('00000008')
--OFN_SHOWHELP                 = toDWORD('00000010')
--OFN_ENABLEHOOK               = toDWORD('00000020')
--OFN_ENABLETEMPLATE           = toDWORD('00000040')
--OFN_ENABLETEMPLATEHANDLE     = toDWORD('00000080')
--OFN_NOVALIDATE               = toDWORD('00000100')
--OFN_ALLOWMULTISELECT         = toDWORD('00000200')
--OFN_EXTENSIONDIFFERENT       = toDWORD('00000400')
OFN_PATHMUSTEXIST            = toDWORD('00000800')
OFN_FILEMUSTEXIST            = toDWORD('00001000')
OFN_CREATEPROMPT             = toDWORD('00002000')
--OFN_SHAREAWARE               = toDWORD('00004000')
--OFN_NOREADONLYRETURN         = toDWORD('00008000')
--OFN_NOTESTFILECREATE         = toDWORD('00010000')
--OFN_NONETWORKBUTTON          = toDWORD('00020000')
--OFN_NOLONGNAMES              = toDWORD('00040000')     // force no long names for 4.x modules
--OFN_EXPLORER                 = toDWORD('00080000')     // new look commdlg
--OFN_NODEREFERENCELINKS       = toDWORD('00100000')
--OFN_LONGNAMES                = toDWORD('00200000')    // force long names for 3.x modules
--OFN_ENABLEINCLUDENOTIFY      = toDWORD('00400000')     // send include message to callback
--OFN_ENABLESIZING             = toDWORD('00800000')


-- windows message --
WM_COMMAND			= toDWORD('0111')


-- input device 
WHEEL_DELTA	=	120	--Default value for rolling one notch


-- file seek --
FILE_BEGIN           = 0
FILE_CURRENT         = 1
FILE_END             = 2
