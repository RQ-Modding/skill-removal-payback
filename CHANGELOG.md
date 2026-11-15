# Changelog

Each section is a version of the mod, the `version` in `mod.json`. The release workflow copies the
section of a tagged version into the release notes.

## 1.2.0

- A load in Loadouts (1.2.0 or newer) gives points back for the skills it erases, as the skill
  window's ERASE would: the skills it learns on the way and erases after, and the starting skills
  the build lacks. Switching builds costs only the builds themselves. The mod's new `erase(iic,
  skill)` (`rq.mod.get("skill-removal-payback")`) is that erasure for any mod that erases for the
  player; `rq.chara.forget` alone still gives nothing.
- A starting skill erased and bought again gives back what it cost, no more: its purchase record
  holds the starting steps too, so the 1 point (or the "Full value" price) is no longer added on
  top. Before, each such round gave a point more than it cost.
- `payback(ctx)` takes `n`, the level of a row that is not there yet (for a plan's price).

## 1.1.0

- A Boost whose effect stays gives nothing back: in the third world, a Boost raised to rank 4
  keeps its effect after an ERASE until the character's skills are reset, so its points were not
  wasted (`rq.chara.on_forget`'s `kept`, loader 2.48.0). Config's new "Points back for kept Boosts"
  gives its cost back as any other skill. A Boost below rank 4, or in another world, pays back as
  before.

## 1.0.0

First version.
- ERASE in the skill window gives back the skill points the skill cost: what was paid for it, as
  the loader records it (loader 2.45.0), or, for a skill bought before that loader, the game's price
  of its steps above the character's starting level, never more than the character has spent.
- A skill the character started with gives back 1 point. Config → Mods → Skill Removal Payback's
  "Full value for starting skills" gives back what the game would charge for it instead.
- A skill a mod gave gives nothing back.
