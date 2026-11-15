# Testing Skill Removal Payback

For people and agents who test the mod in the game. Read it before you use anything the mod adds.
Assume nothing about the mod when it is not installed: check `logs\rqmod.log` for
`Loading skill-removal-payback`.

## What it adds

- **Controls:** no buttons and no `rq.agent.control` ids. Do not invent controls for it.
- **Config → Mods → Skill Removal Payback:** two checkboxes, kept in the profile's `rq.store`:
  `full` ("Full value for starting skills") and `kept` ("Points back for kept Boosts", 1.1.0).
- **Log:** each paid-back ERASE writes `Skill Removal Payback: skill <n> of character <iic>: <points>
  point(s) back (<how>; starting part <n>)`; a mod's erasure for the player (a load in Loadouts)
  adds `, erased by <mod id> for the player`. A starting skill bought again says `bought again from
  nothing` and has starting part 0.

## How to check it

1. Open a character's status page, then **SKILLS** (screen `skill-shop`). Note the free points.
2. Buy a skill (`offer-N`, then Yes), and one more use (`upgrade-N`, then Yes).
3. ERASE it (`forget-N`, then Yes twice). The free points are back to where they were in step 1.
   Without the mod they stay lower.
4. ERASE a skill the character started with: 1 point comes back (with `full` on, its price).
5. ERASE a starting skill, buy it again, ERASE it again: what it cost the second time comes back,
   no more (1.2.0).
6. With Loadouts 1.2.0: load a build that erases skills (see its `TESTING.md`). The question's last
   line says what Skill Removal Payback gives back, and the points after the load are the price
   less that.
7. In the third world only (`rq.world.current() == 3`): raise a Boost (Attack Boost, 277) to rank
   4 and ERASE it. Nothing comes back, the log says `a Boost whose effect stays`, and the Attack
   stays raised (`rq.chara.boosts` lists it `kept`). With `kept` on, its cost comes back. A Boost
   below rank 4 pays back as any skill.

## Forcing it for a test

`rq.chara.learn(iic, skill, { to = n })` buys a skill as the window does, and the record follows.
To look like a purchase made before the record existed, raise a row's most uses with
`rq.ain.set_global("Ｃ", iic, "スキル", row, "使用回数最大", n)` and set its `コスト` to 0. Work on a
copy of the save.

`rq.mod.get("skill-removal-payback")` returns:
- `payback(ctx)`: the points an `on_forget` ctx would give back (`n` for a level the row does not
  have yet),
- `answers_player`: true from 1.2.0, when `rq.chara.forget(iic, skill, { player = true })` gets the
  points back (its third value) and `payback` takes `n`. A plain `rq.chara.forget` gives nothing
  back.
- `settings` (`get`, `set`).

For a kept Boost outside the third world, the Lab sets `rq.ain.set_global("◆ワールド", 3)` and puts
the world back after.

## Test Lab

`skill-payback` (with this mod installed): the window's ERASE of a bought skill, an upgraded one,
an older purchase, a starting skill with `full` off and on, a starting skill bought again, a mod's
gift, and `rq.chara.forget` with and without `player`. `loadouts-paths` (with Loadouts too): what a load's erasures give back, a kept
Boost's ERASE with `kept` off and on, and a Boost below rank 4.
