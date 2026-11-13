# Changelog

Each section is a version of the mod, the `version` in `mod.json`. The release workflow copies the
section of a tagged version into the release notes.

## 1.0.0

First version.
- ERASE in the skill window gives back the skill points the skill cost: what was paid for it, as
  the loader records it (loader 2.45.0), or, for a skill bought before that loader, the game's price
  of its steps above the character's starting level, never more than the character has spent.
- A skill the character started with gives back 1 point. Config → Mods → Skill Removal Payback's
  "Full value for starting skills" gives back what the game would charge for it instead.
- A skill a mod gave gives nothing back.
