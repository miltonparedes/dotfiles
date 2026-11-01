-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
-- Warm gray window borders (Gruvbox).
hl.config({
  general = {
    col = {
      active_border = "rgb(a89984)",
      inactive_border = "rgb(504945)",
    },
  },
})

-- Ultrawide: a lone window opens centered at 16:9 instead of stretching edge to edge.
-- With 2+ windows the normal layout takes over.
hl.config({
  layout = {
    single_window_aspect_ratio = { 16, 9 },
  },
})

-- Keep the main window in the center even with more windows open.
-- A newly opened app takes the center; the previous one moves to the side.
hl.config({
  general = {
    layout = "master",
  },
  master = {
    orientation = "center",
    slave_count_for_center_master = 2, -- 0 gave lone windows a negative width; 2 is the Hyprland default
    new_status = "master",             -- the app you just opened takes the center
    mfact = 0.5,                       -- the center column is half the screen
  },
})
