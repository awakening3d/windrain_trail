
local vr = _new_winds3dvr_ud()

local function _new_pose( pose )
	if (type(pose) ~= "userdata") then error("pose expected") end
	
	local r=_new_udhead_tb(pose)
	
	r.getVelocity = function()
		return vec.new( pose:get_velocity() )
	end

	r.getAngularVelocity = function()
		return vec.new( pose:get_angular_velocity() )
	end

	r.getTrackingResult = function()
		return pose:get_tracking_result()
	end
	
	r.poseIsValid = function()
		return pose:pose_is_valid()
	end

	r.deviceIsConnected = function()
		return pose:device_is_connected()
	end

	return r
end

local function _new_device( deviceid )
	r = {}

	local pose = _new_pose( _new_pose_ud( deviceid ) )
	r.getPose = function()
		return  pose
	end

	r.isConnected = function()
		return pose.deviceIsConnected()
	end

	r.hasTracing = function()
		return pose.poseIsValid()
	end
	
	r.outofRange = function()
		return TrackingResult.Running_OutOfRange==pose.getTrackingResult() or TrackingResult.Calibrating_OutOfRange==pose.getTrackingResult()
	end

	r.isCalibrating = function()
		return TrackingResult.Calibrating_InProgress==pose.getTrackingResult() or TrackingResult.Calibrating_OutOfRange==pose.getTrackingResult()
	end

	r.isUninitialized = function()
		return TrackingResult.Uninitialized==pose.getTrackingResult()
	end

	r.getClass = function()
		return vr:get_tracked_device_class( deviceid )
	end

	r.getMatrix = function()
		local handle = vr:get_tracked_device_matrix( deviceid )
		if (NULL==handle) then return nil end
		return matrix.new(handle)
	end

	return r
end


local function new( vr )
	if (type(vr) ~= "userdata") then error("winds3dvr expected") end

	local get_device_info = function()
		return vr:get_device_info()
	end

	local get_render_resolution = function()
		return vr:get_render_resolution()
	end

	local get_2dbuffer_resolution = function()
		return vr:get_2dbuffer_resolution()
	end


	local get_device = function( index )	-- 1 based index
		return _new_device( index-1 )
	end

	local get_HMD_matrix = function()
		local handle = vr:get_HMD_matrix()
		if (NULL==handle) then return nil end
		return matrix.new(handle)		
	end

	local get_eye_matrix = function(n)
		local handle = vr:get_eye_matrix(n)
		if (NULL==handle) then return nil end
		return matrix.new(handle)		
	end

	local debug_mode = function( n )
		return vr:debug_mode( n )
	end

	local copy_to_host = function( n )
		return vr:copy_to_host( n )
	end
	
	local camera_offset = function( n )
		return vr:camera_offset( n )
	end

	local near_clip = function( n )
		return vr:near_clip(n)
	end
	
	local far_clip = function( n )
		return vr:far_clip(n)
	end

	local fov_scale = function( n )
		return vr:fov_scale(n)
	end

	local unit_scale = function( n )
		return vr:unit_scale(n)
	end
	

	local overlay_show = function( n )
		return vr:overlay_show( n )
	end
	
	local overlay_height = function( n )
		return vr:overlay_height( n )
	end

	local overlay_depth = function( n )
		return vr:overlay_depth( n )
	end

	local overlay_alpha = function( n )
		return vr:overlay_alpha( n )
	end


	local r=_new_udhead_tb(vr)

	r.MaxTrackedDeviceCount = 16

	r.get_device_info = get_device_info
	r.get_render_resolution = get_render_resolution
	r.get_2dbuffer_resolution = get_2dbuffer_resolution
	r.get_device = get_device
	r.get_HMD_matrix = get_HMD_matrix
	r.get_eye_matrix = get_eye_matrix
	r.debug_mode = debug_mode
	r.copy_to_host = copy_to_host
	r.camera_offset = camera_offset

	r.near_clip = near_clip
	r.far_clip = far_clip
	r.fov_scale = fov_scale
	r.unit_scale = unit_scale

	r.overlay_show = overlay_show
	r.overlay_height = overlay_height
	r.overlay_depth = overlay_depth
	r.overlay_alpha = overlay_alpha

	return r
end


-------- export ----------

winds3dvr = new( vr )


function winds3dvr_new_controller( n )

	r = {}

	r.isValid = function()
		return vr:is_controller_valid(n)
	end

	r.getDevice = function()
		local deviceid = vr:get_controller_deviceid(n)
		if deviceid then
			return _new_device( deviceid )
		end
	end


	r.getMatrix = function()
		local handle = vr:get_controller_matrix( n )
		if (NULL==handle) then return nil end
		return matrix.new(handle)
	end

	r.getPosition = function()
		return vec.new( vr:get_controller_position( n ) )
	end

	r.getFront = function()
		return vec.new( vr:get_controller_front( n ) )
	end

	r.getRight = function()
		return vec.new( vr:get_controller_right( n ) )
	end

	r.getUp = function()
		return vec.new( vr:get_controller_up( n ) )
	end

	r.getDeviceID = function()
		return vr:get_controller_deviceid( n )
	end

	r.isButtonPressed = function( buttonid )
		return vr:is_controller_button_pressed( n, buttonid )
	end

	r.isButtonTouched = function( buttonid )
		return vr:is_controller_button_touched( n, buttonid )
	end

	r.getAxis = function( buttonid )
		return vr:get_controller_axis( n, buttonid )
	end

	local PulseInterval = 0.1
	r.setPulseInterval = function( interval )
		local oldvalue = PulseInterval
		PulseInterval = interval
		return oldvalue
	end

	local lastPulseTime = 0
	r.triggerHapticPulse = function( durationMicroSec, buttonid )
		local nowtime = GetAppTime()
		if nowtime - lastPulseTime < PulseInterval then return end
		lastPulseTime = nowtime
		return vr:trigger_controller_haptic_pulse( n, durationMicroSec, buttonid )
	end

	return r
end

ControllerA = winds3dvr_new_controller(1)
ControllerB = winds3dvr_new_controller(2)


-------- tracked device class ------------
TrackedDeviceClass =
{
	Invalid = 0,				-- the ID was not valid.
	HMD = 1,				-- Head-Mounted Displays
	Controller = 2,			-- Tracked controllers
	GenericTracker = 3,		-- Generic trackers, similar to controllers
	TrackingReference = 4,		-- Camera and base stations that serve as tracking reference points
	DisplayRedirect = 5,		-- Accessories that aren't necessarily tracked themselves, but may redirect video output from other tracked devices
}

-------- device tracking result -----------
TrackingResult =
{
	Uninitialized			= 1,

	Calibrating_InProgress	= 100,
	Calibrating_OutOfRange	= 101,

	Running_OK				= 200,
	Running_OutOfRange		= 201,
}

------   VR controller button and axis IDs --------
ControllerButtonID = 
{
	System			= 0,
	ApplicationMenu	= 1,
	Grip				= 2,
	DPad_Left			= 3,
	DPad_Up			= 4,
	DPad_Right		= 5,
	DPad_Down			= 6,
	A				= 7,
	
	ProximitySensor   = 31,

	Axis0				= 32,
	Axis1				= 33,
	Axis2				= 34,
	Axis3				= 35,
	Axis4				= 36,

	-- aliases for well known controllers
	Touchpad	= 32,
	Trigger	= 33,

	Dashboard_Back	= 2,

	Max				= 64
}

--------- VR Event Type --------
VREvent = 
{
	None = 0,

	TrackedDeviceActivated		= 100,
	TrackedDeviceDeactivated	= 101,
	TrackedDeviceUpdated		= 102,
	TrackedDeviceUserInteractionStarted	= 103,
	TrackedDeviceUserInteractionEnded	= 104,
	IpdChanged					= 105,
	EnterStandbyMode			= 106,
	LeaveStandbyMode			= 107,
	TrackedDeviceRoleChanged	= 108,
	WatchdogWakeUpRequested		= 109,
	LensDistortionChanged		= 110,
	PropertyChanged				= 111,

	ButtonPress					= 200, -- data is controller
	ButtonUnpress				= 201, -- data is controller
	ButtonTouch					= 202, -- data is controller
	ButtonUntouch				= 203, -- data is controller

	MouseMove					= 300, -- data is mouse
	MouseButtonDown				= 301, -- data is mouse
	MouseButtonUp				= 302, -- data is mouse
	FocusEnter					= 303, -- data is overlay
	FocusLeave					= 304, -- data is overlay
	Scroll						= 305, -- data is mouse
	TouchPadMove				= 306, -- data is mouse
	OverlayFocusChanged			= 307, -- data is overlay, global event

	InputFocusCaptured			= 400, -- data is process DEPRECATED
	InputFocusReleased			= 401, -- data is process DEPRECATED
	SceneFocusLost				= 402, -- data is process
	SceneFocusGained			= 403, -- data is process
	SceneApplicationChanged		= 404, -- data is process - The App actually drawing the scene changed (usually to or from the compositor)
	SceneFocusChanged			= 405, -- data is process - New app got access to draw the scene
	InputFocusChanged			= 406, -- data is process
	SceneApplicationSecondaryRenderingStarted = 407, -- data is process

	HideRenderModels			= 410, -- Sent to the scene application to request hiding render models temporarily
	ShowRenderModels			= 411, -- Sent to the scene application to request restoring render model visibility

	OverlayShown				= 500,
	OverlayHidden				= 501,
	DashboardActivated			= 502,
	DashboardDeactivated		= 503,
	DashboardThumbSelected		= 504, -- Sent to the overlay manager - data is overlay
	DashboardRequested			= 505, -- Sent to the overlay manager - data is overlay
	ResetDashboard				= 506, -- Send to the overlay manager
	RenderToast					= 507, -- Send to the dashboard to render a toast - data is the notification ID
	ImageLoaded					= 508, -- Sent to overlays when a SetOverlayRaw or SetOverlayFromFile call finishes loading
	ShowKeyboard				= 509, -- Sent to keyboard renderer in the dashboard to invoke it
	HideKeyboard				= 510, -- Sent to keyboard renderer in the dashboard to hide it
	OverlayGamepadFocusGained	= 511, -- Sent to an overlay when IVROverlay::SetFocusOverlay is called on it
	OverlayGamepadFocusLost		= 512, -- Send to an overlay when it previously had focus and IVROverlay::SetFocusOverlay is called on something else
	OverlaySharedTextureChanged = 513,
	DashboardGuideButtonDown	= 514,
	DashboardGuideButtonUp		= 515,
	ScreenshotTriggered			= 516, -- Screenshot button combo was pressed, Dashboard should request a screenshot
	ImageFailed					= 517, -- Sent to overlays when a SetOverlayRaw or SetOverlayfromFail fails to load
	DashboardOverlayCreated		= 518,

	-- Screenshot API
	RequestScreenshot				= 520, -- Sent by vrclient application to compositor to take a screenshot
	ScreenshotTaken					= 521, -- Sent by compositor to the application that the screenshot has been taken
	ScreenshotFailed				= 522, -- Sent by compositor to the application that the screenshot failed to be taken
	SubmitScreenshotToDashboard		= 523, -- Sent by compositor to the dashboard that a completed screenshot was submitted
	ScreenshotProgressToDashboard	= 524, -- Sent by compositor to the dashboard that a completed screenshot was submitted

	PrimaryDashboardDeviceChanged	= 525,

	Notification_Shown				= 600,
	Notification_Hidden				= 601,
	Notification_BeginInteraction	= 602,
	Notification_Destroyed			= 603,

	Quit							= 700, -- data is process
	ProcessQuit						= 701, -- data is process
	QuitAborted_UserPrompt			= 702, -- data is process
	QuitAcknowledged				= 703, -- data is process
	DriverRequestedQuit				= 704, -- The driver has requested that SteamVR shut down

	ChaperoneDataHasChanged			= 800,
	ChaperoneUniverseHasChanged		= 801,
	ChaperoneTempDataHasChanged		= 802,
	ChaperoneSettingsHaveChanged	= 803,
	SeatedZeroPoseReset				= 804,

	AudioSettingsHaveChanged		= 820,

	BackgroundSettingHasChanged		= 850,
	CameraSettingsHaveChanged		= 851,
	ReprojectionSettingHasChanged	= 852,
	ModelSkinSettingsHaveChanged	= 853,
	EnvironmentSettingsHaveChanged	= 854,
	PowerSettingsHaveChanged		= 855,
	EnableHomeAppSettingsHaveChanged = 856,

	StatusUpdate					= 900,

	MCImageUpdated					= 1000,

	FirmwareUpdateStarted			= 1100,
	FirmwareUpdateFinished			= 1101,

	KeyboardClosed					= 1200,
	KeyboardCharInput				= 1201,
	KeyboardDone					= 1202, -- Sent when DONE button clicked on keyboard

	ApplicationTransitionStarted		= 1300,
	ApplicationTransitionAborted		= 1301,
	ApplicationTransitionNewAppStarted	= 1302,
	ApplicationListUpdated				= 1303,
	ApplicationMimeTypeLoad				= 1304,
	ApplicationTransitionNewAppLaunchComplete = 1305,
	ProcessConnected					= 1306,
	ProcessDisconnected					= 1307,

	Compositor_MirrorWindowShown		= 1400,
	Compositor_MirrorWindowHidden		= 1401,
	Compositor_ChaperoneBoundsShown		= 1410,
	Compositor_ChaperoneBoundsHidden	= 1411,

	TrackedCamera_StartVideoStream  = 1500,
	TrackedCamera_StopVideoStream   = 1501,
	TrackedCamera_PauseVideoStream  = 1502,
	TrackedCamera_ResumeVideoStream = 1503,
	TrackedCamera_EditingSurface    = 1550,

	PerformanceTest_EnableCapture	= 1600,
	PerformanceTest_DisableCapture	= 1601,
	PerformanceTest_FidelityLevel	= 1602,

	MessageOverlay_Closed			= 1650,
	
	-- Vendors are free to expose private events in this reserved region
	VendorSpecific_Reserved_Start	= 10000,
	VendorSpecific_Reserved_End		= 19999,
}

------- you can process vr event in this function --------
-- function _onVREvent( eventType, deviceID, eventAgeSeconds, pdata )
-- 	print( 'on vr event', eventType, deviceID, eventAgeSeconds, pdata )
-- end

 function _onTrackedDeviceChange( poseCount, controllerCount )
	print( 'on tracked device change PoseCount: '..poseCount..' ControllerCount: '..controllerCount )
 end

function _onControllerButtonStateChange( eventType, deviceID, eventAgeSeconds, databutton )
	local r,g,b,a = DWORDtoRGBA( databutton )
	local buttonid = math.floor( b*255 + 0.5 )

	local ctrlname = 'unknown'
	if deviceID == ControllerA.getDeviceID() then ctrlname = 'CtrlA' end
	if deviceID == ControllerB.getDeviceID() then ctrlname = 'CtrlB' end
	--print( 'on button state:', ctrlname, eventType, deviceID, eventAgeSeconds, buttonid )

	if VREvent.ButtonPress == eventType then
		if onControllerButtonPress then onControllerButtonPress( deviceID, buttonid ) end
	elseif VREvent.ButtonUnpress == eventType then
		if onControllerButtonUnpress then onControllerButtonUnpress( deviceID, buttonid ) end
	elseif VREvent.ButtonTouch == eventType then
		if onControllerButtonTouch then onControllerButtonTouch( deviceID, buttonid ) end
	elseif VREvent.ButtonUntouch == eventType then
		if onControllerButtonUntouch then onControllerButtonUntouch( deviceID, buttonid ) end
	end
end

-- generate mouse message by ray & overlay and send to app
local lastmousex, lastmousey = nil, nil
local lastlbuttonpressed = false

function mouse_message_by_ray( ctrl, ray, winwidth, winheight )

	local overlayheight = winds3dvr.overlay_height(0)
	winds3dvr.overlay_height( overlayheight )
	local overlaydepth =  winds3dvr.overlay_depth(0)
	winds3dvr.overlay_depth( overlaydepth )
	overlayheight =  overlayheight
	--local viewinv = finalcamera.getInvViewMatrix()
	local viewinv = camera.getViewMatrix() * winds3dvr.get_HMD_matrix()
	viewinv.inverse()

	local a = viewinv * vec.new( -100,  overlayheight, overlaydepth )
	local b = viewinv * vec.new(  100,  overlayheight, overlaydepth )
	local c = viewinv * vec.new(  100, -overlayheight, overlaydepth )
	local d = viewinv * vec.new( -100, -overlayheight, overlaydepth )

	local x,y = nil, nil
	local inter, t, u, v =  RayIntersectTriangle( ray.getOrg(), ray.getDir(), a, b, d )
	if inter then
		x,y = u,v
	else
		inter, t, u, v =  RayIntersectTriangle( ray.getOrg(), ray.getDir(), c, d, b )
		if inter then
			x,y = 1-u, 1-v
		end
	end

	if not x then return end -- no intersect with overlay panel
	
	local mousex = math.floor(winwidth * x)
	local mousey = math.floor(winheight * y)
	if lastmousex ~= mousex  or lastmousey ~= mousey then
		lastmousex, lastmousey = mousex, mousey
		wnd.PostMessage( GetMainWnd(), WM_MOUSEMOVE, NULL, toDWORD( mousey, mousex ) )
	end

	local lbuttonpressed = ctrl.isButtonPressed( ControllerButtonID.Trigger ) 
	if lastlbuttonpressed ~= lbuttonpressed then
		if lbuttonpressed then
			wnd.PostMessage( GetMainWnd(), WM_LBUTTONDOWN, NULL, toDWORD( mousey, mousex ) )
		else
			wnd.PostMessage( GetMainWnd(), WM_LBUTTONUP, NULL, toDWORD( mousey, mousex ) )
		end
		lastlbuttonpressed = lbuttonpressed
	end

end