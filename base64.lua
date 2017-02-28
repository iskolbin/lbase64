--[[ 
 
 base64 -- v1.2.0 public domain Lua base64 encoder/decoder
 no warranty implied; use at your own risk
 
 Needs bit32.extract function. If not present it's implemented using BitOp
 or Lua 5.3 native bit operators. For Lua 5.1 fallback to pure Lua 
 implementation taken from David's Manura numberlua library
 (https://github.com/davidm/lua-bit-numberlua). Original license for the
 library is

 ============================================================================
 Copyright (C) 2008, David Manura.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 =============================================================================

 author: Ilya Kolbin (iskolbin@gmail.com)
 url: github.com/iskolbin/lbase64

 COMPATIBILITY

 Lua 5.1, 5.2, 5.3, LuaJIT 1, 2

 LICENSE

 This software is dual-licensed to the public domain and under the following
 license: you are granted a perpetual, irrevocable license to copy, modify,
 publish, and distribute this file as you see fit.

--]]

local char, concat = string.char, table.concat

local base64 = {}
-- Taken from numberlua by David Manura
-- https://github.com/davidm/lua-bit-numberlua/blob/master/lmod/bit/numberlua.lua
local extract = bit32 and bit32.extract
if not extract then
	if bit then
		local shl, shr, band = bit.lshift, bit.rshift, bit.band
		extract = function( v, from, width )
			return band( shr( v, from ), shl( 1, width ) - 1 )
		end
	elseif _G._VERSION >= "Lua 5.3" then
		extract = load[[return function( v, from, width )
			return ( v >> from ) & ((1 << width) - 1)
		end]]()
	else
		local setmetatable, floor = _G.setmetatable, math.floor
		local function memoize(f)
			local mt = {}
			local t = setmetatable({}, mt)
			function mt:__index(k)
				local v = f(k)
				t[k] = v
				return v
			end
			return t
		end
		
		local function make_bitop_uncached(t, m)
			local function bitop(a, b)
				local res, p = 0, 1
				while a ~= 0 and b ~= 0 do
					local am, bm = a%m, b%m
					res = res + t[am][bm]*p
					a, b, p = (a - am) / m, (b - bm) / m, p*m
				end
				res = res + (a+b)*p
				return res
			end
			return bitop
		end

		local op1 = make_bitop_uncached({[0]={[0]=0,[1]=1},[1]={[0]=1,[1]=0}}, 2^1 )
		local op2 = memoize( function(a)
			return memoize( function(b)
				return op1(a, b)
			end)
		end)

		local bxor = make_bitop_uncached(op2, 2^4)
		
		extract = function( v, from, width )
			local a, b = floor(v % 2^32 / 2^from), 2^width - 1
			return ((a+b) - bxor(a,b))/2
		end
	end
end

function base64.makeencoder( s62, s63, spad )
	return {[0]='A','B','C','D','E','F','G','H','I','J',
		'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
		'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n',
		'o','p','q','r','s','t','u','v','w','x','y','z','0','1','2',
		'3','4','5','6','7','8','9',s62 or '+',s63 or'/',spad or'='}
end

function base64.makedecoder( s62, s63, spad )
	local decoder = {}
	for char, b64code in pairs{
		A=0, B=1, C=2, D=3, E=4, F=5, G=6, H=7, I=8, J=9, K=10,L=11,
		M=12,N=13,O=14,P=15,Q=16,R=17,S=18,T=19,U=20,V=21,W=22,X=23,
		Y=24,Z=25,a=26,b=27,c=28,d=29,e=30,f=31,g=32,h=33,i=34,j=35,
		k=36,l=37,m=38,n=39,o=40,p=41,q=42,r=43,s=44,t=45,u=46,v=47,
		w=48,x=49,y=50,z=51,
		['0']=52, ['1']=53, ['2']=54, ['3']=55, ['4']=56, ['5']=57,
		['6']=58, ['7']=59, ['8']=60, ['9']=61,
		[s62 or '+']=62,
		[s63 or'/']=63,
		[spad or '='] = 0} do
		decoder[char:byte()] = b64code
	end
	return decoder
end

local DEFAULT_ENCODER = base64.makeencoder()
local DEFAULT_DECODER = base64.makedecoder()

function base64.encode( str, encoder )
	encoder = encoder or DEFAULT_ENCODER
	local t, k, n = {}, 1, #str
	local lastn = n % 3
	local cache = {}
	for i = 1, n-lastn, 3 do
		local a, b, c = str:byte( i, i+2 )
		local v = a*0x10000 + b*0x100 + c
		local s = cache[v]
		if not s then
			s = encoder[extract(v,18,6)] .. encoder[extract(v,12,6)] .. encoder[extract(v,6,6)] .. encoder[extract(v,0,6)]
			cache[v] = s
		end
		t[k] = s
		k = k + 1
	end
	if lastn == 2 then
		local a, b = str:byte( n-1, n )
		local v = a*0x10000 + b*0x100--*0x100
		t[k] = encoder[extract(v,18,6)]
		t[k+1] = encoder[extract(v,12,6)]
		t[k+2] = encoder[extract(v,6,6)]
		t[k+3] = '='
	elseif lastn == 1 then
		local v = str:byte( n )*0x10000
		t[k] = encoder[extract(v,18,6)]
		t[k+1] = encoder[extract(v,12,6)]
		t[k+2] = '=='
	end
	return concat( t ) 
end

function base64.decode( b64 )
	decoder = decoder or DEFAULT_DECODER
	local t, k = {}, 1
	local cache = {}
	local n = #b64
	local padding = b64:sub(-2) == '==' and 2 or b64:sub(-1) == '=' and 1 or 0
	for i = 1, padding > 0 and n-4 or n, 4 do
		local a, b, c, d = b64:byte( i, i+3 )
		local v0 = a*0x1000000 + b*0x10000 + c*0x100 + d
		local s = cache[v0]
		if not s then
			local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
			s = char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
			cache[v0] = s
		end
		t[k] = s
		k = k + 1
	end
	if padding == 1 then
		local a, b, c = b64:byte( n-3, n-1 )
		local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40
		t[k] = char( extract(v,16,8), extract(v,8,8))
	elseif padding == 2 then
		local a, b = b64:byte( n-3, n-2 )
		local v = decoder[a]*0x40000 + decoder[b]*0x1000
		t[k] = char( extract(v,16,8))
	end
	return concat( t )
end

return base64
