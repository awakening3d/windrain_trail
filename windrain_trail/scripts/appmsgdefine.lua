--app message define
IDM_OPEN_FILE				=	toDWORD('9c4d')
IDM_CONFIG_DISPLAY			=	toDWORD('9c42')
IDM_CONFIG_INPUT			=	toDWORD('9c4b')
IDM_STOP_SHOT				=	toDWORD('9C51')
IDM_PAUSE				=	toDWORD('9c63')
IDM_TOGGLE_CONSOLE          =   toDWORD('66')
IDM_LIMIT_FPS			= toDWORD('67')

IDM_ABOUT                   =	toDWORD('9c54')
IDM_DEVICE_MESSAGE		= toDWORD('9c52')
IDM_TOGGLE_FULLSCREEN		= toDWORD('9c43')

-- input style
INPUT_STYLE_AXIS	=	toDWORD('00000001') -- axis
INPUT_STYLE_LRUD	=	toDWORD('00000002') -- left,right,up,down
INPUT_STYLE_WSAD	=	toDWORD('00000004') -- w,s,a,d
INPUT_STYLE_CAMERA	=	toDWORD('00000008') -- camera
INPUT_STYLE_JD		=	toDWORD('00000010') -- jump,duck
INPUT_STYLE_EX		=	toDWORD('00000020') -- extended
INPUT_STYLE_CONFIG	=	toDWORD('00000040') -- config
