-- Config

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,

		border_size = 0,

		layout = "dwindle",
	},

	decoration = {
		rounding = 10,

		blur = {
			enabled = true,
			size = 3,
			passes = 2,
			new_optimizations = true,
		},
	},

	animations = {
		enabled = true,
	},

	dwindle = {
		preserve_split = true,
	},

	input = {
		follow_mouse = 2,
		kb_options = "ctrl:nocaps",
	},

	misc = {
		focus_on_activate = true,
		enable_anr_dialog = false,
	},
})

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

hl.on("hyprland.start", function()
	hl.exec_cmd("~/.config/hypr/scripts/startup.sh")
end)

-- Env

hl.env("NVD_BACKEND", "direct")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bitbata-modern")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")

hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- Rules

hl.workspace_rule({ workspace = "1", default = true, monitor = "VIRT-1" })

hl.layer_rule({
	name = "bar",
	match = { namespace = "gtk-layer-shell" },

	ignore_alpha = 0,
	blur = true,
	no_anim = true,
})
hl.layer_rule({
	name = "vicinae",
	match = { namespace = "vicinae" },

	ignore_alpha = 0,
	blur = true,
	no_anim = true,
})

hl.config({ binds = { disable_keybind_grabbing = true } })

-- Keybinds

local mainMod = "SUPER"

hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("vicinae vicinae://extensions/vicinae/clipboard/history"))
hl.bind(
	mainMod .. " + B",
	hl.dsp.exec_cmd(
		"hyprctl -j getoption binds:disable_keybind_grabbing | jq -r '.bool | not' | xargs -I{} hyprctl eval 'hl.config({ binds = { disable_keybind_grabbing = {} } })'"
	)
)

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
