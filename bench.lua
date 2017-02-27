local base64 = require'base64'
local N = 10000000
local t = {}
local letters = ' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890абвгдеёжзийклмнопрстуфхцшщчъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦШЩЧЪЫЬЭЮЯ'
local nletters = #letters
for i = 1, N do
	local j = math.random( nletters )
	t[i] = letters:sub( nletters, nletters )
end
local s = table.concat( t )

local t = os.clock()
local encoded = base64.encode( s )
local encodetime = os.clock() - t

t = os.clock()
local decoded = base64.decode( encoded )
local decodetime = os.clock() - t

assert( s == decoded )
print(('Encoding: %d bytes/sec'):format( N/encodetime ))
print(('Decoding: %d bytes/sec'):format( N/decodetime ))

