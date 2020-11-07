pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- lakeside
-- by sestrenexsis
-- github.com/sestrenexsis/lakeside

--[[
based on
advanced micro platformer
by @matthughson
lexaloffle.com/bbs/?tid=28793
--]]

_me="sestrenexsis"
_cart="lakeside"
--cartdata(_me.."_".._cart.."_1")
--_version=1

_minx=64
_maxx=960

_layers={
--{tx,ty,tw,th,ox,oy,sc}
	{ 0,48,16,16,0,0,32.0},
	{16,48, 2,16,0,0,16.0},
	{18,48, 2,16,0,0,4.0},
	{20,48, 2,16,0,0,1.0},
	{22,48, 4,16,0,0,0.8}
}

_anims={
	idle={{1},1,false},
	walk={{2,1,0,1},4,true},
	jump={{3},1,false},
	duck={{4},1,false}
}

_bbox={
	idle={2,2,4,13},
	walk={2,2,4,13},
	jump={2,2,4,13},
	duck={2,5,4,10}
}

function hit(
	x, -- x position : number
	y  -- y position : number
	)
	local res=false
	local idx=mget(x/8,y/8)
	local flg=fget(idx,0)
	if flg then
		res=true
	end
	return res
end

jump={}

function jump:new()
	local obj={
		pres=false,
		down=false,
		tiks=0,
		grnd=false
	}
	return setmetatable(
		obj,{__index=self}
	)
end

function jump:update(
	b, -- input  : bool
	p  -- player : table
	)
	self.pres=false
	if b then
		if not self.down then
			self.pres=true
		end
		self.down=true
		self.tiks+=1
	else
		self.down=false
		self.pres=false
		self.tiks=0
	end
end

person={}

function person:new(
	x, -- x position : number
	y  -- y position : number
	)
	local obj={
		x=x,
		y=y,
		dx=0,
		dy=0,
		lx=x,
		ly=y,
		dk=false,
		jp=jump:new(),
		ann="idle",
		ant=t(),
		hts={},
		fc=6
	}
	return setmetatable(
		obj,{__index=self}
	)
end

function person:update()
	self.lx=self.x
	self.ly=self.y
	self.dx=mid(-2,self.dx,2)
	self.dy=mid(-16,self.dy+0.5,16)
	while #self.hts>0 do
		deli(self.hts,#self.hts)
	end
	-- side hit checks
	local b=_bbox[self.ann]
	local y0=self.y-16+b[2]
	local y1=y0+b[4]
	local x0=self.x+b[1]
	local x1=x0+b[3]
	for i=0,abs(self.dx) do
		local x=x0
		if (
			self.dx>0 or
			self.dx>=0 and self.fc==6
			) then
			x=x1
		end
		x+=sgn(self.dx)*i
		local h0=hit(x,y0)
		local h1=hit(x,y1)
		add(self.hts,{x,y0,h0})
		add(self.hts,{x,y1,h1})
		if h0 or h1 then
			if i<2 then
				self.dx=0
			else
				self.dx=sgn(self.dx)*(i-1)
			end
			break
		end
	end
	self.x+=self.dx
	if self.dx<0 then
		self.fc=4
	elseif self.dx>0 then
		self.fc=6
	end
	-- world edges
	if self.x<_minx then
		self.x=_minx
	elseif self.x>=_maxx then
		self.x=_maxx
	end
	-- floor/ceiling hit checks
	local gv=true
	self.jp.grnd=false
	for i=0,ceil(abs(self.dy)) do
		local y=y0
		if self.dy>0 then
			dn=true
			y=y1
		elseif self.dy<0 then
			gv=false
		end
		y+=sgn(self.dy)*i
		local h0=hit(x0,y)
		local h1=hit(x1,y)
		add(self.hts,{x0,y,h0})
		add(self.hts,{x1,y,h1})
		if (h0 or h1) and gv then
			self.jp.grnd=true
		end
		if h0 or h1 then
			if i<2 then
				self.dy=0
			else
				self.dy=sgn(self.dy)*(i-1)
			end
			break
		end
	end
	self.y+=self.dy
	if not self.jp.grnd then
		self.ann="jump"
	elseif self.dx==0 then
		if self.dk then
			self.ann="duck"
		else
			self.ann="idle"
		end
	else
		if self.ann!="walk" then
			self.ant=t()
		end
		self.ann="walk"
	end
end

function person:draw()
	local an=_anims[self.ann]
	local frames=an[1]
	local speed=an[2]
	local loop=an[3]
	local idx=flr(
		speed*(t()-self.ant)
		)
	if loop then
		idx=1+idx%#frames
	else
		idx=min(#frames,1+idx)
	end
	local ani=frames[idx]
	local fx=self.fc==4
	spr(
		ani,self.x,self.y-16,1,2,fx
		)
	for ht in all(self.hts) do
			local x=ht[1]
			local y=ht[2]
			local h=ht[3]
			if h then
				pset(x,y,14)
			else
				pset(x,y,8)
			end
	end
	if self.jmp then
		local x=self.x+3
		local y=self.y-9
		rectfill(x-1,y-1,x+1,y+1,11)
	end
end

cam={}

function cam:new(
	f -- focus
	)
	local obj={
		f=f,      -- focus
		x=f.x,
		y=0,
		apron=4, -- apron
	}
	return setmetatable(
		obj,{__index=self}
	)
end

function cam:update()
	local mxx=self.x+self.apron
	local mnx=self.x-self.apron
	if mxx<self.f.x then
		self.x+=min(4,self.f.x-mxx)
	elseif mnx>self.f.x then
		self.x+=min(4,self.f.x-mnx)
	end
	if self.x<_minx then
		self.x=_minx
	elseif self.x>_maxx then
		self.x=_maxx
	end
end
-->8
-- game loop

function _init()
	_p=person:new(96,96)
	_cam=cam:new(_p)
	music(0)
end

function _update()
	_p.dx=0
	if btn(⬇️) then
		_p.dk=true
		if btn(⬅️) then
			_p.fc=4
		elseif btn(➡️) then
			_p.fc=6
		end
	else
		_p.dk=false
		if btn(⬅️) then
			_p.dx=-2
		elseif btn(➡️) then
			_p.dx=2
		end
	end
	if btnp(❎) or btnp(🅾️) then
		if _p.jp.grnd then
			_p.dy=-6
		end
	end
	_p:update()
	_cam:update()
end

function drawlayer(c,l)
	local sw=8*l[3]
	local sh=8*l[4]
	local sx=l[5]
	local sy=l[6]
	sx=(sx-c.x)/l[7]
	--sy=(sy+c.y)/l[7]
	repeat
		map(
			l[1],l[2],sx,sy,l[3],l[4]
			)
		sx+=sw
	until sx>=128
end

function _draw()
	cls(2)
	camera()
	for l in all(_layers) do
		if l[7]>1 then
			drawlayer(_cam,l)
		end
	end
	camera(_cam.x-64,_cam.y)
	map(0,0,0,0,128,128)
	_p:draw()
	camera()
	for l in all(_layers) do
		if l[7]<1 then
			drawlayer(_cam,l)
		end
	end
	print(_cam.x,0,0,1)
	print(_p.x,0,6,1)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222000002220000022200000222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222000002220000022200000222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000000220000002200000022001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000001002220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00220001002200000022000002220010002220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222011002220000122200220222100000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222100012220001122202222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20222000012222001022220000222000022200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222000011222000122200000222000022220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000000220000002200000022000202220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000000220000000200000022100222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00220000001200000010220002220010002222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02200010001200000100022020000010001122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02000001001200000100002022000011001210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02200001001222000110002200000000012220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000333b333399949999bbb3bbbbcc77cccc0000000000001100000000000000000000000000000000000000000022222222000000000000000000000000
000000003bb3bb3399999999bbbbbbbbcccccccc000000000000111000000000000000000000000000000000000000002dddddd2000000000000000000000000
000000003333333b99999994bbbbbbb3cccccccc000000000001331100000000000000000000000000000000000000002dddddd2000000000000000000000000
00000000bb333bb399999999bbbbbbbbcccccccc000000000011331100000000000000000000000000000000000000002dddddd2000000000000000000000000
00000000333b333399949999bbb3bbbbcccc7777000000000113131110000000000000000000000000000000000000002dddddd2000000000000000000000000
000000003bb3bb3399999999bbbbbbbbcccccccc0c000c000133111110001100000000000000000000000000000000002dddddd2000000000000000000000000
000000003333333b99999994bbbbbbb3ccccccccccc0ccc001b3311111013310000000000000000000000000000000002dddddd2000000000000000000000000
00000000bb333bb399999999bbbbbbbbccccccccc7ccc7cc01b13331111131100000000000000000000000000000000022222222000000000000000000000000
ddddddddddddddddddddd777777ddddddddddddddddddddd113111113113b3100000000000000000000000000000000000000000000000000000000000000000
ddddddddddddddddddd7777777777ddddddddddddddddddd33331311311313310000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddd777777777777ddddddddddddddddddbb33131133b331110000000000000000000000000000000000000000000000000000000000000000
ddddddddddddddddd77777777777777dddddddddddddddddb31313311b3133110000000000000000000000000000000000000000000000000000000000000000
ddddddddddddddddd77777777777777ddddddddddddddddd333133113b3111110000000000000000000000000000000000000000000000000000000000000000
ddddddddddddddd77777777777777777777777777ddddddd13133111333311311000000000000000000000000000000000000000000000000000000000000000
dddddddddddddd7777777777777777777777777777dddddd13111113131131111111000000000000000000000000001100000000000000000000000000000000
ddddddddddddd777777777777777777777777777777ddddd1b331131113111111111100000000000000000000000000100000000000000000000000000000000
eeeeeeeedddddd777777777777dddddddddddddddddddddd13111111111113111111010000000000000000000000001100000000000000000000000000000000
ddddddddddddddd7777777777ddddddddddddddddddddddd13311111311131111111100000000000000000000000011100000000000000000000000000000000
eeeeeeeedddddddddddddddddddddddddddddddddddddddd13111311111131111110000000000000000000000001011100000000000000000000000000000000
eeeeeeeedddddddddddddddddddddddddddddddddddddddd11111111311111111111011000000000000000000001101100000000000000000000000000000000
eeeeeeeedddddddddddddddddddddddddddddddddddddddd11113111111133111111111100000000000000000101111100000000000000000000000000000000
eeeeeeeedddddddddddddddddddddddddddddddddddddddd31113111311331111111110100000000000000001110111100000000000000000000000000000000
eeeeeeeedddddddddddddddddddddddddddddddddddddddd13133333333333311111111100000000000000101111111100000000000000000000000000000000
eeeeeeeedddddddddddddddddddddddddddddddddddddddd11111111111111111111111101000000000011111111111100000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000011111111111111111111111110000000001000111111111100000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000011111111111111111111111111101001001111111111111100000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000011111111111111111111111111110000111111110111111100000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000013313111131111311111111111111111111111111111111100000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000033333333333333331111111111111111111111111111111100000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000033333333333333331111111111111111111111111111111100000000000000000000000000000000
eeeeeeee300000030000000000000000000000000000000033333333333333331111111111111111111111111111111100000000000000000000000000000000
eeeeeeee330000330000000000000000000000000000000011111111111111111111111111111111111111111111111100000000000000000000000000000000
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
15253545455505050505050505050505040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16262626263605051545452535550505040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505050505051626262626360505040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06060606060606060606060606060606040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06060606060606060606060606060606647404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707070707070707070707070707657504040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404667604040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404677754540404040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040444440404040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040444441717040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040404041414040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040404042424040404040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040404042424b48494040000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040404043434b58595a50000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040404043434b68696a60000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404040404040404040404040404040404043434b78797a70000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404c4c4c4c40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
404040404040404040404040404040404040404040404040404c404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
7171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171
4141414141414141414141414141414c4141414141414c414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141
4242424242424242424c4242424242424242424242424c424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242
4242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242
4343434c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4343434343434343434343434343434343434343434143434343434343434343434343434343434343434343414343434343434343434343434343434343434343434143434343434343434343434343434343434343434343434343434143434343
4343414343434343434343434343434343434341434343434343434343434343434343434343434341414343434343434343434343434343434343434343434141434343434343434343434343434343434343434341414343434343434343434343434343434343434343434343434341414343434343434343434343434343
4343434343434341434343434343434343434343434343434343414343434343414343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343
__sfx__
011000200013200205001450000000033000001001200000001340612100000000450003300000100141001200134000450012500000000331001204004100120013400521000250011500033001250000310012
011000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 00424344

