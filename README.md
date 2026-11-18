# Skill Removal Payback

ERASE in a character's skill window gives back the skill points the skill cost, so trying out a
build no longer wastes points.

## Showcase

### Removing a Skill and getting Points

<img width="834" height="798" alt="20261118-1239-27 7675108-ezgif com-optimize" src="https://github.com/user-attachments/assets/20cdaaf7-5c9b-46eb-9762-95f06f0a03ed" />

### Mod Options

<img width="1261" height="918" alt="image" src="https://github.com/user-attachments/assets/7059a8fd-f542-4494-b442-249c86753dae" />


## What it changes

- **A skill you bought** gives back every point you paid for it, uses and ranks included. The mod
  reads what was paid from the record RQ MOD keeps of each purchase.
- **A skill bought before you installed the mod** (or before RQ MOD 2.45.0) has no record. The mod
  works out what it cost: the steps above what the character started with, at the price the game
  charges for them. It never gives back more points than the character has spent in all.
- **A skill the character started with** gives back 1 point. With **Full value for starting skills**
  on, it gives back what the game would charge for it, or still 1 when the game does not sell that
  skill to that character.
- **A skill another mod gave** gives nothing back.
- **A Boost whose effect stays** gives nothing back by default. In the third world, a Boost raised
  to rank 4 (Stamina, Attack, Magic, Accuracy, Evasion, Critical, Resilience and Stun Boost, and the
  second Stamina, Attack and Magic Boost) keeps its effect after an ERASE, until the character's
  skills are reset (Morurun's reset, Skill Again), so erasing it wastes nothing. With **Points back
  for kept Boosts** on, it gives back what it cost, as any other skill. In the other worlds the
  effect goes with the skill, and the Boost pays back as any other skill.
- **Another mod erasing a skill for you** pays back as ERASE would, when that mod says the erasure
  is yours (RQ MOD 2.51.0). A load in [Loadouts](https://github.com/RQ-Modding/loadouts) does: the skills it learns on the way and erases after, and the starting skills the build
  lacks. Loadouts shows the points that come back before you load, so switching between builds
  costs only the builds.
- Only these erasures pay back. Morurun's reset already gives every point back, and the skills the
  story takes away, or a mod removes for its own reasons, give nothing, as before.
- **A starting skill you erased and bought again** gives back what you paid for it the second
  time, which already includes its starting level.

Two cases are guessed for skills bought before the record existed: a skill a story event gave looks
bought when the character's skill list also sells it (the "spent in all" limit keeps that from
giving extra points), and a starting skill you erased and bought again looks like the starting one
(it gives back 1).

## Keys and settings

- **Config → Mods → Skill Removal Payback**: **Full value for starting skills** and **Points back
  for kept Boosts** (both off by default). The settings are kept in the save profile.

## Saves

Nothing of the mod stays in a save: the points it gave back are the character's, as if never spent.
The setting is kept in `rqmod-store.json` in the save profile; the game ignores it.

## Install

Needs [RQ MOD](https://github.com/RQ-Modding/RQ-Mod) with loader **2.52.0** or newer. Extract the
release zip into the game's `mods` folder, so that you have `mods/skill-removal-payback/mod.json`.

## How it works

`rq.chara.on_forget` runs before the game empties the skill's row; for an erasure the player
chose (its `player`: the ERASE button, the game's `キャラスキル_消去`, or a mod's `rq.chara.forget`
with `player = true`) the mod returns the points, and the loader adds them to the character.
`rq.chara.forget_points` asks the same before an erasure (`preview`), and the mod answers it the
same way, so another mod can show the price of a change that erases skills. The
record is `on_forget`'s `cost`, and its `kept` tells a Boost whose effect stays; older purchases
use `rq.chara.base_skills` (the starting skills, as Morurun's reset rebuilds them),
`rq.chara.price` and `rq.chara.skill_points_max`.

## License

MIT, see [LICENSE](LICENSE).
