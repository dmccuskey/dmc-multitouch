--====================================================================--
-- MultiTouch Basic
--
-- Drag a square with one finger; move, pinch and rotate it with two
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2012-2015 David McCuskey. All Rights Reserved.
--====================================================================--



print( '\n\n##############################################\n\n' )



--====================================================================--
--== Imports


local MultiTouch = require 'dmc_corona.dmc_multitouch'



--====================================================================--
--== Setup, Constants


local W, H = display.contentWidth, display.contentHeight
local H_CENTER, V_CENTER = W*0.5, H*0.5

display.setStatusBar( display.HiddenStatusBar )



--====================================================================--
--== Main
--====================================================================--


local function main()

	local o = display.newRect( H_CENTER, V_CENTER, 150, 150 )
	o:setFillColor( 0.2, 0.6, 1 )

	-- one or two fingers move it, two fingers scale and rotate it
	MultiTouch.activate( o, 'move', { 'single', 'multi' } )
	MultiTouch.activate( o, 'scale', 'multi', { minScale=0.5, maxScale=3 } )
	MultiTouch.activate( o, 'rotate', 'multi' )

	o:addEventListener( MultiTouch.MULTITOUCH_EVENT, function( event )
		print( 'multitouch', event.phase, event.x, event.y, event.direction )
	end )

end


-- start the action !

main()
