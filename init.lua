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
-- Only the skill window's ERASE (キャラスキル_消去): Morurun's reset already gives every point back,
-- and the game's own removals in the story give nothing.

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
    { kind = "space", h = 8 },
    { kind = "label", dim = true, size = 15,
      text = "Bought skills always give back what they cost." },
  },
}

-- The skill's level in its row: most uses for a use skill, rank for a ranked one.
local function level(iic, ctx)
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
    start = 1
    if settings.get("full") then start = math.max(rq.chara.price(iic, skill, 0, base) or 1, 1) end
  end
  return bought + start, how, start
end

rq.chara.on_forget(function(ctx)
  if ctx.caller ~= ERASE then return nil end
  local ok, back, how, start = pcall(payback, ctx)
  if not ok then
    rq.log(MOD .. ": " .. tostring(back))
    return nil
  end
  rq.log(("%s: skill %d of character %d: %d point(s) back (%s; starting part %d)"):format(
    MOD, ctx.skill, ctx.iic, back, how, start))
  return back
end)

rq.log(MOD .. " loaded")

-- For tests and other mods (rq.mod.get("skill-removal-payback")): the settings and what an ERASE
-- of a row would give back (ctx as rq.chara.on_forget's: iic, skill, slot, rank, cost).
return {
  settings = settings,
  payback = function(ctx) return (payback(ctx)) end,
}
