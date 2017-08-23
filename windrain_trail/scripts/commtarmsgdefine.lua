--commtar message define

-- mouse message
MOUSE_PRESS	=	toDWORD('1') -- press The mouse button is pressed while the pointer is over the button. 
MOUSE_RELEASE	=	toDWORD('2') -- release The mouse button is released while the pointer is over the button. 
MOUSE_RELEASE_OUTSIDE	=	toDWORD('3') -- releaseOutside The mouse button is released while the pointer is outside the button.  
MOUSE_ROLL_OVER	=	toDWORD('4') -- rollOver The mouse pointer rolls over the button. 
MOUSE_ROLL_OUT	=	toDWORD('5') -- rollOut The pointer rolls outside of the button area. 
MOUSE_DRAG_OVER	=	toDWORD('6') -- dragOver While the pointer is over the button, the mouse button has been pressed while rolled outside the button, and then rolled back over the button. 
MOUSE_DRAG_OUT	=	toDWORD('7') -- dragOut While the pointer is over the button, the mouse button is pressed and then rolls outside the button area. 

--shot message
SHOT_BEGIN	=	toDWORD('100')
SHOT_END	=	toDWORD('101')
SHOT_TIMER	=	toDWORD('102')

--render to texture message
RTT_BEGIN	=	toDWORD('200')
RTT_END		=	toDWORD('201')
