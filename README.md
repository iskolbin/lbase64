![Build Status](https://travis-ci.org/iskolbin/lbase64.svg?branch=master)
[![license](https://img.shields.io/badge/license-public%20domain-blue.svg)]()

Lua base64 encoder/decoder
==========================

Pure Lua [base64](https://en.wikipedia.org/wiki/Base64) encoder/decoder. Works with 
Lua 5.1+ and LuaJIT. Fallbacks to pure Lua bit operations if bit/bit32/native bit 
operators is not available (using 
[numberlua library](https://github.com/davidm/lua-bit-numberlua) by David Manura).

```lua
local base64 = require'base64'
local str = 'Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.'
local b64str = 'TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=' 
local encoded = base64.encode( str )
local decoded = base64.decode( b64str )
assert( str == decoded )
assert( b64str == encoded )
```

base64.encode( str, encoder = DEFAULT, usecache = false )
---------------------------------------------------------
Encodes `str` string using `encoder` table. By default uses table with `+` as
char for 62, `/` as char for 63 and `=` as padding char. You can specify custom
encoder. For this you could use `base64.makeencoder`. If you are encoding large
chunks of text (or another highly redundant data) it's possible to highly
increase performace (for text approx. x2 gain) by using `usecache = true`. For
binary data like images using cache decreasing performance.

base64.decode( str, decoder = DEFAULT, usecache = false )
---------------------------------------------------------
Decodes `str` string using `decoder` table. Default decoder uses same chars as
default encoder.

base64.makeencoder( s62 = '+', s63 = '/', spad = '=' )
------------------------------------------------------
Make custom encoding table

base64.makedecoder( s62 = '+', s63 = '/', spad = '=' )
------------------------------------------------------
Make custom decoding table
