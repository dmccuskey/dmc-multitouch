--====================================================================--
-- tests/dmc_multitouch_spec.lua
--
-- unit tests for dmc_multitouch, with a stand-in Touch Manager
-- run with tests/run_unit.sh
--====================================================================--


module( ..., package.seeall )


--====================================================================--
--== Setup

-- stand-in Touch Manager: records calls, keeps the handler
local TM = {}
TM.register = function( obj, handler ) TM.calls[#TM.calls+1]={ 'register', obj, handler } ; TM.handler=handler end
TM.unregister = function( obj, handler ) TM.calls[#TM.calls+1]={ 'unregister', obj, handler } end
TM.setFocus = function( obj, id ) TM.calls[#TM.calls+1]={ 'setFocus', obj, id } end
TM.unsetFocus = function( obj, id ) TM.calls[#TM.calls+1]={ 'unsetFocus', obj, id } end
package.loaded.dmc_touchmanager = TM

-- the boot sets its own globals; snapshot after it
pcall( function() require( 'dmc_corona_boot' ) end )
local globals = {}
for k in pairs( _G ) do globals[k] = true end

local MultiTouch = require 'dmc_corona.dmc_multitouch'

local o, events

local function newObject()
	local obj = { x=200, y=270, xScale=1, yScale=1, rotation=0 }
	function obj:dispatchEvent( e ) events[#events+1] = e end
	return obj
end

local function T( phase, id, x, y )
	return TM.handler{ name='touch', phase=phase, id=id, x=x, y=y, target=o, isFocused=( phase~='began' ) }
end

-- two touches on either side of the object's centre, turned by
-- `turn` degrees (trig, counter-clockwise) and spread to `r` over n moves
local function twoFingers( turn, r, n )
	local A, B = {}, {}
	T( 'began', A, o.x-50, o.y ) ; T( 'began', B, o.x+50, o.y )
	local cx, cy = o.x, o.y
	local ax, ay, bx, by
	for i = 1, n do
		local a = math.rad( turn*i/n ) ; local d = 50 + ( r-50 )*i/n
		ax, ay = cx - d*math.cos( a ), cy + d*math.sin( a )
		bx, by = cx + d*math.cos( a ), cy - d*math.sin( a )
		T( 'moved', A, ax, ay ) ; T( 'moved', B, bx, by )
	end
	T( 'ended', A, ax, ay ) ; T( 'ended', B, bx, by )
end

local function near( a, b ) return math.abs( a-b ) < 0.01 end

function setup()
	TM.calls, TM.handler, events = {}, nil, {}
	o = newObject()
end


--====================================================================--
--== Tests

function test_loadSetsNoGlobals()
	for k in pairs( _G ) do
		assert_true( globals[k] or k=='dmc_multitouch_spec', 'new global: ' .. tostring( k ) )
	end
	assert_equal( '0.4.1', MultiTouch.VERSION )
end

function test_registersObjectWithTouchManager()
	MultiTouch.activate( o, 'move', 'single' )
	assert_equal( 'register', TM.calls[1][1] )
	assert_equal( o, TM.calls[1][2] )
	assert_equal( 'function', type( TM.calls[1][3] ) )
end

function test_deactivateUnregisters()
	MultiTouch.activate( o, 'move', 'single' )
	local h = TM.handler
	MultiTouch.deactivate( o )
	local c = TM.calls[#TM.calls]
	assert_equal( 'unregister', c[1] ) ; assert_equal( o, c[2] ) ; assert_equal( h, c[3] )
	assert_nil( o.__dmc.multitouch )
end

function test_focusOnTheObject()
	MultiTouch.activate( o, 'move', 'single' )
	local A = {}
	T( 'began', A, 200, 270 ) ; T( 'ended', A, 200, 270 )
	local focus, unfocus
	for _, c in ipairs( TM.calls ) do
		if c[1]=='setFocus' then focus=c elseif c[1]=='unsetFocus' then unfocus=c end
	end
	assert_equal( o, focus[2] ) ; assert_equal( A, focus[3] )
	assert_equal( o, unfocus[2] ) ; assert_equal( A, unfocus[3] )
end

function test_singleDrag()
	MultiTouch.activate( o, 'move', 'single' )
	local A = {}
	T( 'began', A, 190, 260 )
	T( 'moved', A, 210, 275 )
	T( 'moved', A, 230, 290 )
	T( 'ended', A, 230, 290 )
	assert_true( near( o.x, 240 ) ) ; assert_true( near( o.y, 300 ) )
	assert_equal( 'began', events[1].phase ) ; assert_equal( 'ended', events[#events].phase )
	assert_equal( MultiTouch.MULTITOUCH_EVENT, events[1].name )
end

function test_moveBounds()
	MultiTouch.activate( o, 'move', 'single', { xBounds={ nil, 220 } } )
	local A = {}
	T( 'began', A, 200, 270 ) ; T( 'moved', A, 300, 280 ) ; T( 'ended', A, 300, 280 )
	assert_true( near( o.x, 220 ) ) ; assert_true( near( o.y, 280 ) )
end

function test_pinchScales()
	MultiTouch.activate( o, 'scale', 'multi' )
	twoFingers( 0, 100, 4 )
	assert_true( near( o.xScale, 2 ) ) ; assert_true( near( o.yScale, 2 ) )
end

function test_pinchScaleLimits()
	MultiTouch.activate( o, 'scale', 'multi', { maxScale=1.5 } )
	twoFingers( 0, 100, 4 )
	assert_true( near( o.xScale, 1.5 ) )
end

function test_rotateBothWays()
	MultiTouch.activate( o, 'rotate', 'multi' )
	-- trig counter-clockwise is Corona's negative rotation (y down)
	twoFingers( 90, 50, 6 )
	assert_true( near( o.rotation, -90 ), o.rotation )
	o = newObject() ; MultiTouch.activate( o, 'rotate', 'multi' )
	twoFingers( -90, 50, 6 )
	assert_true( near( o.rotation, 90 ), o.rotation )
end

function test_rotatePastHalfTurn()
	MultiTouch.activate( o, 'rotate', 'multi' )
	twoFingers( -300, 50, 12 )
	assert_true( near( o.rotation, 300 ), o.rotation )
end

function test_rotateDirection()
	MultiTouch.activate( o, 'rotate', 'multi' )
	twoFingers( -60, 50, 3 )
	local moved
	for _, e in ipairs( events ) do if e.phase=='moved' then moved=e end end
	assert_equal( 'clockwise', moved.direction )
end

function test_dragFromTheCentre()
	-- no scale action: the touch on the centre has no distance to divide by
	MultiTouch.activate( o, 'move', 'single' )
	local A = {}
	T( 'began', A, 200, 270 ) ; T( 'moved', A, 250, 300 ) ; T( 'ended', A, 250, 300 )
	assert_true( near( o.x, 250 ), o.x ) ; assert_true( near( o.y, 300 ), o.y )
end

function test_twoFingerMoveWithoutRotate()
	-- turning the fingers moves the object only with the midpoint
	MultiTouch.activate( o, 'move', 'multi' )
	twoFingers( 90, 50, 6 )
	assert_true( near( o.x, 200 ), o.x ) ; assert_true( near( o.y, 270 ), o.y )
	assert_equal( 0, o.rotation )
end

function test_distanceDeltaIsDistanceMoved()
	-- without a scale action too; 30 across, 40 down is 50
	MultiTouch.activate( o, 'move', 'single' )
	local A = {}
	T( 'began', A, 190, 260 ) ; T( 'moved', A, 220, 300 ) ; T( 'ended', A, 220, 300 )
	assert_equal( 0, events[1].distanceDelta )
	assert_true( near( events[2].distanceDelta, 50 ), events[2].distanceDelta )
end

function test_deactivateWithoutActivate()
	MultiTouch.deactivate( o )
	o.__dmc = {} ; MultiTouch.deactivate( o )
	assert_equal( 0, #TM.calls )
end

function test_unknownActionIsAnError()
	local ok, err = pcall( MultiTouch.activate, o, 'spin', 'single' )
	assert_false( ok )
	assert_match( "unknown action 'spin'", err )
	assert_equal( 0, #TM.calls ) -- nothing registered
	assert_nil( o.__dmc )
end
