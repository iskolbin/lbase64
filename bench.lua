local base64 = require'base64'
local N = 10000000
local st = {}
local letters = ' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890абвгдеёжзийклмнопрстуфхцшщчъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦШЩЧЪЫЬЭЮЯ'
local nletters = #letters
for i = 1, N do
	local j = math.random( nletters )
	st[i] = letters:sub( nletters, nletters )
end
local s = table.concat( st )
local t = os.clock()
local encoded = base64.encode( s )
local encodetime = os.clock() - t

t = os.clock()
local decoded = base64.decode( encoded )
local decodetime = os.clock() - t

assert( s == decoded )
print('Common text')
print(('Encoding: %d bytes/sec'):format( math.floor(N/encodetime)))
print(('Decoding: %d bytes/sec'):format( math.floor(N/decodetime)))
collectgarbage()

local t = os.clock()
local encoded = base64.encode( s, nil, true )
local encodetime = os.clock() - t

t = os.clock()
local decoded = base64.decode( encoded, nil, true )
local decodetime = os.clock() - t
print('Common text (cache)')
print(('Encoding: %d bytes/sec'):format( math.floor(N/encodetime)))
print(('Decoding: %d bytes/sec'):format( math.floor(N/decodetime)))
collectgarbage()

local lt = {}
for i = 0, 255 do
	lt[i] = string.char(i)
end
local nletters = #lt
for i = 1, N do
	local j = math.random( nletters )
	st[i] = lt[j]
end
local s = table.concat( st )

local t = os.clock()
local encoded = base64.encode( s, nil )
local encodetime = os.clock() - t

t = os.clock()
local decoded = base64.decode( encoded )
local decodetime = os.clock() - t

assert( s == decoded )
print('Binary')
print(('Encoding: %d bytes/sec'):format( math.floor(N/encodetime)))
print(('Decoding: %d bytes/sec'):format( math.floor(N/decodetime)))
collectgarbage()

local t = os.clock()
local encoded = base64.encode( s, nil, true )
local encodetime = os.clock() - t

t = os.clock()
local decoded = base64.decode( encoded, nil, true )
local decodetime = os.clock() - t
print('Binary (cache)')
print(('Encoding: %d bytes/sec'):format( math.floor(N/encodetime)))
print(('Decoding: %d bytes/sec'):format( math.floor(N/decodetime)))
collectgarbage()

