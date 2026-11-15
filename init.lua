-- Skill Removal Payback: ERASE in the skill window gives back the skill points the skill cost.
-- API reference: https://rq-modding.github.io/rq-modding-docs/reference/
--
-- What one ERASE gives back (notes/plans/plan-new-mods.md in the workspace, section 1):
--   the bought steps   the purchase record (rq.chara.on_forget's cost, loader 2.45.0). A skill bought
--                      before that loader has no record: its steps above the starting level
--                      (rq.chara.base_skills) at the game's price (rq.chara.price), never more than
--                      the character has spent in all (rq.chara.skill_points_max - free points)
--   the starting part  1 point for a skill the character starts with; with "Full value" on, what the
--                      game would charge for its starting level (1 when the game does not sell it)
--   a mod's gift       nothing (the record is -1)
--   a kept Boost       nothing, unless "Points back for kept Boosts" is on: a Boost at rank 4 whose
--                      effect the game keeps after the ERASE (the third world; rq.chara.on_forget's
--                      kept, loader 2.48.0) was not wasted
-- A starting skill erased and bought again has a record that holds its starting steps too: no
-- starting part on top (1.2.0; before, each such round gave 1 point more than it cost).
-- Only the skill window's ERASE (キャラスキル_消去), and a mod's erasures for the player through
-- this mod's erase (Loadouts, when it loads a build: 1.2.0). Morurun's reset already gives every
-- point back, the game's own removals in the story give nothing, and so does rq.chara.forget.

local MOD = "Skill Removal Payback"
local ERASE = "キャラスキル_消去"

local settings = rq.config.settings{
  id = "skill-removal-payback",
  title = MOD,
  keep = "profile",
  rows = {
    { kind = "checkbox", key = "full", label = "Full value for starting skills", default = false,
      note = {
        "Off: a skill the character started with gives back 1 point.",
        "On: what the game would charge for it, or 1 when the game does not sell it.",
      } },
    { kind = "checkbox", key = "kept", label = "Points back for kept Boosts", default = false,
      note = {
        "Off: erasing a Boost whose effect the game keeps (one at its top rank, in the third world) gives nothing back.",
        "On: it gives back what it cost, as any other skill.",
      } },
    { kind = "space", h = 8 },
    { kind = "label", dim = true, size = 15,
      text = "Other bought skills always give back what they cost." },
  },
}

-- The skill's level in its row: most uses for a use skill, rank for a ranked one. ctx.n, when
-- given, is the level (a plan's, for a row that is not there yet).
local function level(iic, ctx)
  if math.type(ctx.n) == "integer" then return ctx.n end
  local t = rq.skill.get(ctx.skill).type
  if t == 20 or t == 30 then return ctx.rank end
  if t ~= 10 then return 1 end
  for _, s in ipairs(rq.chara.slots(iic)) do
    if s.slot == ctx.slot then return s.max end
  end
  return 1
end

local function start_level(iic, skill)
  for _, s in ipairs(rq.chara.base_skills(iic)) do
    if s.id == skill then return s.n end
  end
  return 0
end

-- The points one ERASE gives back, and a line for the log.
local function payback(ctx)
  local iic, skill = ctx.iic, ctx.skill
  if ctx.kept and not settings.get("kept") then return 0, "a Boost whose effect stays", 0 end
  local now = level(iic, ctx)
  local base = math.min(start_level(iic, skill), now)
  local bought, how = 0, "nothing bought"
  if ctx.cost > 0 then
    bought, how = ctx.cost, "recorded"
  elseif ctx.cost == 0 and now > base then
    local p = rq.chara.price(iic, skill, base, now)
    if p then
      local spent = rq.chara.skill_points_max(iic) - rq.chara.skill_points(iic)
      bought = math.max(0, math.min(p, spent))
      how = ("older purchase, %d at the game's price, %d spent in all"):format(p, spent)
    else
      how = "older steps the game does not sell now"
    end
  elseif ctx.cost == -1 then
    how = "given by a mod"
  end
  local start = 0
  if base > 0 then
    -- Erased and bought again: the record holds the starting steps already.
    local whole = ctx.cost > 0 and rq.chara.price(iic, skill, 0, now) or nil
    if whole and ctx.cost >= whole then
      how = how .. ", bought again from nothing"
    else
      start = 1
      if settings.get("full") then start = math.max(rq.chara.price(iic, skill, 0, base) or 1, 1) end
    end
  end
  return bought + start, how, start
end

-- The erasure erase() makes, while it runs: { iic, skill, back }.
local as_player = nil

rq.chara.on_forget(function(ctx)
  local mine = as_player ~= nil and ctx.caller == "lua" and ctx.iic == as_player.iic
    and ctx.skill == as_player.skill
  if ctx.caller ~= ERASE and not mine then return nil end
  local ok, back, how, start = pcall(payback, ctx)
  if not ok then
    rq.log(MOD .. ": " .. tostring(back))
    return nil
  end
  rq.log(("%s: skill %d of character %d: %d point(s) back (%s; starting part %d)%s"):format(
    MOD, ctx.skill, ctx.iic, back, how, start, mine and ", erased by a mod for the player" or ""))
  if mine then as_player.back = back end
  return back
end)

-- Erases a skill as the skill window's ERASE does, with its points back: for a mod that erases for
-- the player, as Loadouts does when it loads a build. Returns whether the character had the skill
-- and the points given back.
local function erase(iic, skill)
  if math.type(iic) ~= "integer" or math.type(skill) ~= "integer" then
    error("skill-removal-payback: erase(iic, skill) takes two whole numbers", 2)
  end
  if as_player then error("skill-removal-payback: erase is already running", 2) end
  as_player = { iic = iic, skill = skill, back = 0 }
  local ok, removed = pcall(rq.chara.forget, iic, skill)
  local back = as_player.back
  as_player = nil
  if not ok then error(removed, 2) end
  return removed == true, removed == true and back or 0
end

rq.log(MOD .. " loaded")

-- For tests and other mods (rq.mod.get("skill-removal-payback")):
--   settings          the Config page's settings
--   payback(ctx)      what an ERASE of a row would give back (ctx as rq.chara.on_forget's: iic,
--                     skill, slot, rank, cost, kept; n for a level the row does not have yet)
--   erase(iic, skill) erases as the skill window's ERASE does, with the points back (1.2.0)
return {
  settings = settings,
  payback = function(ctx) return (payback(ctx)) end,
  erase = erase,
}
