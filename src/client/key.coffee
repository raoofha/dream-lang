key =
  ENTER: 13
  TAB: 9
  DELETE : 46
  INSERT : 45
  PAUSE: 19
  SCROLL: 145
  BACKSPACE : 8
  LEFT : 37
  RIGHT : 39
  UP : 38
  DOWN : 40
  HOME : 36
  END : 35
  PAGE_UP : 33
  PAGE_DOWN : 34
  SHIFT: 16
  CTRL: 17
  ALT: 18
  ESCAPE: 27
  META: 91
  HYPER: 0
  F1: 112
  F2: 113
  F3: 114
  F4: 115
  F5: 116
  F6: 117
  F7: 118
  F8: 119
  F9: 120
  F10: 121
  F11: 122
  F12: 123

special = {}
for k,v of key
  special[k] = v
key.special = special

for k in [64..90]
  key[String.fromCharCode k] = k

module.exports = key
