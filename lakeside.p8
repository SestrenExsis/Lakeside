pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- lakeside
-- by sestrenexsis
-- github.com/sestrenexsis/lakeside

_me="sestrenexsis"
_cart="lakeside"
--cartdata(_me.."_".._cart.."_1")
--_version=1

person={}

function person:new(
	x, -- x position : number
	y  -- y position : number
	)
	local obj={
		x=x,
		y=y,
		an=0,
		fc=6
	}
	return setmetatable(
		obj,{__index=self}
	)
end

function person:update()
	if t()%0.25==0 then
		self.an=(self.an+1)%4
	end
end

function person:draw()
	local fx=self.f==4
	spr(
		self.an,64,self.y,1,2,fx
		)
end

function _init()
	_p=person:new(64,56)
end

function _update()
	if btn(⬅️) then
		_p.x-=1
		_p.f=4
	elseif btn(➡️) then
		_p.x+=1
		_p.f=6
	end
	_p:update()
end

function _draw()
	cls()
	local sx=-(_p.x%128)
	map(0,0,sx/16,0,32,2)
	map(0,2,sx/8,16,32,2)
	map(0,4,sx/4,32,32,2)
	map(0,6,sx/2,48,32,2)
	map(0,8,sx,64,32,2)
	_p:draw()
	map(0,10,1.25*sx,80,96,2)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ddd00000ddd00000ddd00000ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ddd00000ddd00000ddd00000ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd000000dd000000dd000000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dd000100dd000000dd000000dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dddd01100ddd00001ddd00d00ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddd10001ddd00011ddd0dd01ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0ddd00001dddd0010dddd0001dddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dddd000011ddd0001ddd000011ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd000000dd000000dd000000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd000000dd0000000d000000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dd0000001d00000010dd00001d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dd00010001d000001000dd0001d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d000001001d0000010000d0001d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dd00001001ddd00011000dd001ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333b333399949999bbb3bbbbcc77cccc555555551111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
3bb3bb3399999999bbbbbbbbcccccccc555556556666111100000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333b99999994bbbbbbb3cccccc77555556651661111100000000000000000000000000000000000000000000000000000000000000000000000000000000
bb333bb399999999bbbbbbbbcccccccc555555551111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
333b333399949999bbb3bbbbcc77cccc566555551111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
3bb3bb3399999999bbbbbbbbcccccccc565555551111666600000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333b99999994bbbbbbb3cccccc77555555551111166100000000000000000000000000000000000000000000000000000000000000000000000000000000
bb333bb399999999bbbbbbbbcccccccc555555551111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
