; Jacob comments:
; overall your code looks really good!

turtles-own[
  wear-mask?
  vaccinated?
  isolation?
  home-patch
  distancing?
  test-period
  infected?
  infection-rate
  day
  recover-day
]

patches-own [
  home-patch?
  isolate-patch?
  school-patch?
]
globals [wear-masks social-distance vaccinate isolate positive-turtle recover death task-taken confirm-positive]

to setup
  clear-all
  set-patches
  set-turtle
  reset-ticks
end

to set-patches
  ;;Set up home patch
  ask patches [set pcolor white]
  ask patches with [abs pycor > 8] [
    set home-patch? true
    set pcolor brown
  ]
  ;;School patches
  ask patches with [abs pxcor < 7 and abs pycor < 6 ] [
    set school-patch? true
    set pcolor blue
  ]
  ;;isolation room
  ask patches with [ pxcor < 15 and pxcor > 10 and pycor < 3 and pycor > -5] [
    set isolate-patch? true
    set pcolor green
  ]
  set recover 0
  set death 0
end

to set-turtle
    calculate-population
    create-turtles population [
    set color green
    set shape "person"
    set size 1
    set wear-mask? false
    set infected? false
    set distancing? false
    set vaccinated? false
    set isolation? false
    set infection-rate 0
    set day 0
    set test-period 7 + random 14
    move-to one-of patches with [home-patch? = true]
    set home-patch patch-here
  ]
  ;;Assign positive patients
   ask n-of Positive-case turtles [
   set color red
   set infected? true
  ]
   ask n-of wear-masks turtles [
   set wear-mask? true
  ]
   ask n-of vaccinate turtles [
   set vaccinated? true
  ]
   ask n-of social-distance turtles [
   set distancing? true
  ]

   ask n-of isolate turtles [
   set isolation? true
  ]
  set positive-turtle Positive-case
end


to go
  set task-taken 0
  set confirm-positive 0
  ask turtles-on patches with [home-patch? = true][
    test-covid
  ]
  ask turtles-on patches with [school-patch? = true][
    move-around
    calculate-infection-rate
  ]
  ;;Check if the isolated turtle can go back home
  ask turtles-on patches with [isolate-patch? = true][
    ifelse recover-day = 0 [
      set recover recover + 1
      set color sky
      set infected? false
      go-home
    ] [
      check-death
      set recover-day recover-day - 1
    ]
  ]
  ask turtles-on patches with [school-patch? = true][
    if infected? = true [spread-covid]
    go-home
  ]
  tick
end

to test-covid
  ifelse day mod test-period = 0 [
    set task-taken task-taken + 1
    ifelse infected? = true [
      check-death
      set confirm-positive confirm-positive + 1
      set color red
      ifelse isolation? = true [
        move-to one-of patches with [isolate-patch? = true]
        start-isolation
      ][go-school]]
    [
      set color green
      go-school
    ]
    set day 0
  ]
  [set day day + 1]
end

to start-isolation
  set recover-day random 14 + 7
end

to go-school
  move-to one-of patches with [school-patch? = true]
end

to go-home
  move-to home-patch
end

to spread-covid  ; {{{To keep with standard NetLogo style, change this to "spread-covid"}}}
  ask other turtles with [not infected?] in-radius 1[
  if random-float 100 < infection-rate [
      set infected? true
      set color orange
    ]
  ]
end

to move-around
  repeat 3 [move-to one-of patches with [school-patch? = true]]
end

to calculate-infection-rate
  ifelse wear-mask? = true [
    set infection-rate random-float 30
  ][set infection-rate 33 ]

  ifelse vaccinated? = true [
    set infection-rate infection-rate + random-float 30]
  [set infection-rate infection-rate + 33]

  ifelse distancing? = true [
   set infection-rate infection-rate + random-float 30]
  [set infection-rate infection-rate + 33]

end

to calculate-population
  set wear-masks Wearing-mask / 100 * population
  set vaccinate vaccination / 100 * population
  set social-distance Social-Distancing / 100 * population
  set isolate isolation / 100 * population
end

to check-death
  ifelse turtles-on patches with [isolate-patch? = true] = true [
    if random-float 100 < Mortality-Rate / 2 [
      set death death + 1
      die
    ]
  ][
    if random-float 100 < Mortality-Rate [
      set death death + 1
      die
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
732
10
1404
683
-1
-1
16.21212121212121
1
10
1
1
1
0
1
1
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
735
695
828
742
Set Up
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
70
69
242
102
Population
Population
0
1000
793.0
1
1
NIL
HORIZONTAL

SLIDER
69
123
241
156
Positive-Case
Positive-Case
0
Population
2.0
1
1
NIL
HORIZONTAL

SLIDER
70
182
242
215
Wearing-Mask
Wearing-Mask
0
100
100.0
1
1
%
HORIZONTAL

SLIDER
70
239
242
272
Vaccination
Vaccination
0
100
65.0
1
1
%
HORIZONTAL

SLIDER
70
295
243
328
Social-Distancing
Social-Distancing
0
100
12.0
1
1
%
HORIZONTAL

SLIDER
71
350
243
383
Isolation
Isolation
0
100
11.0
1
1
%
HORIZONTAL

PLOT
316
16
686
254
Positive vs Negative
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"positive-case" 1.0 0 -2674135 true "" "plot count turtles with [infected?] / Population "
"negative-case" 1.0 0 -13840069 true "" "plot count turtles with [not infected?] / Population "
"recovery-case" 1.0 0 -13791810 true "" "plot recover / isolate"

BUTTON
853
694
947
740
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
315
277
407
322
Positive Case
count turtles with [infected?]
17
1
11

MONITOR
314
356
454
401
Positive Rate / Tasks
confirm-positive / task-taken
4
1
11

MONITOR
433
277
533
322
Negative Case
count turtles with [not infected?]
17
1
11

MONITOR
565
277
631
322
Isolating
count turtles-on patches with [isolate-patch? = true]
17
1
11

MONITOR
471
355
528
400
Death
death
17
1
11

SLIDER
71
403
243
436
Mortality-Rate
Mortality-Rate
0
100
4.3
0.1
1
%
HORIZONTAL

MONITOR
570
355
701
400
Current Population
count turtles
17
1
11

PLOT
311
433
681
642
Task Taken v.s. Confirmed Positive
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Task-Taken" 1.0 0 -11053225 true "" "plot task-taken"
"Confirmed-Cases" 1.0 0 -2674135 true "" "plot confirm-positive"

@#$#@#$#@
## WHAT IS IT?

This is a COVID-19 simulation model made by Kana Huang. In this model, you are able to explore the microworld I created which simulates a school under covid-19. 

## HOW IT WORKS
 Every ticks, turtles will head to the school and interact with other turtles. Then, they will go back home. Sounds like our daily rountine,right? However, due to this microworld is under pandemic, virus is spreading among these turtles. Each turtle has various test day in which they can take covid test. Then, for those who are tested positive, they could consider if they want to go to hospital and isolate. Noticed that positive turtles will also die, but those who decide to go to hosptial would have less mortality chance than those continue go to school. 

## HOW TO USE IT

User can adjust the parameters to simulate how students could spread the virus at school. After setting the input value, user need to hit Set up and Go to start the simulation. 

## QUESTIONS TO THINK ABOUT 

1.	Can you achieve a zero positive rate environment? 
2.	Can you let all the turtles infected? 
3.	Can you predict the infection pattern?

## EXTENDING THE MODEL

Can you try extending this model to some more complicative model? Considering add some more vairables that could enrich the model, such as fixed birth rate, more accurate infection rate calculation. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
