# Testing Skill Removal Payback

For people and agents who test the mod in the game. Read it before you use anything the mod adds.
Assume nothing about the mod when it is not installed: check `logs\rqmod.log` for
`Loading skill-removal-payback`.

## What it adds

- **Controls:** no buttons and no `rq.agent.control` ids. Do not invent controls for it.
- **Config → Mods → Skill Removal Payback:** one checkbox, `full` ("Full value for starting
  skills"), kept in the profile's `rq.store`.
- **Log:** each paid-back ERASE writes `Skill Removal Payback: skill <n> of character <iic>: <points>
  point(s) back (<how>; starting part <n>)`.

## How to check it

1. Open a character's status page, then **SKILLS** (screen `skill-shop`). Note the free points.
2. Buy a skill (`offer-N`, then Yes), and one more use (`upgrade-N`, then Yes).
3. ERASE it (`forget-N`, then Yes twice). The free points are back to where they were in step 1.
   Without the mod they stay lower.
4. ERASE a skill the character started with: 1 point comes back (with `full` on, its price).

## Forcing it for a test

`rq.chara.learn(iic, skill, { to = n })` buys a skill as the window does, and the record follows.
To look like a purchase made before the record existed, raise a row's most uses with
`rq.ain.set_global("Ｃ", iic, "スキル", row, "使用回数最大", n)` and set its `コスト` to 0. Work on a
copy of the save.

## Test Lab

`skill-payback` (with this mod installed): the window's ERASE of a bought skill, an upgraded one,
an older purchase, a starting skill with `full` off and on, and a mod's gift.
