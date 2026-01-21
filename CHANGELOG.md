# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Pending
- [ ] Test on different Hyprland versions

### Completed
- [x] Make Waybar colors dynamic based on selected theme
- [x] Initial configuration created
- [x] 13 color themes implemented
- [x] Install script with NVIDIA support
- [x] Fixed `animations:first_launch_animation` error
- [x] Fixed deprecated layerrule syntax
- [x] Extended keybindings (40+ shortcuts)
- [x] Fixed `decoration:drop_shadow` - now uses `shadow {}` subcategory
- [x] Fixed `decoration:shadow_range` - now `shadow { range = }` 
- [x] Fixed `decoration:shadow_render_power` - now `shadow { render_power = }`
- [x] Fixed `decoration:col.shadow` - now `shadow { color = }`
- [x] Fixed `decoration:shadow_offset` - now `shadow { offset = }`
- [x] Fixed `master:new_is_master` - removed (deprecated)
- [x] Fixed `gestures:workspace_swipe` - replaced with new `gesture =` syntax
- [x] Updated Waybar to island-style separated modules
- [x] Each Waybar module now has rounded borders and individual styling

---

## [1.0.1] - 2026-01-21

### Fixed
- Hyprland config compatibility with latest version
- Shadow configuration now uses subcategory syntax
- Gestures use new `gesture = 3, horizontal, workspace` syntax
- Removed deprecated master layout options

### Changed
- Waybar redesigned with island-style modules
- Each module is a separate rounded container
- Improved visual hierarchy with colored borders

---

## [1.0.0] - 2026-01-21

### Added
- Initial release
- 13 color schemes (X, Madrid, Lahabana, Seul, Miami, Paris, Tokio, Oslo, Helsinki, Berlin, London, Praha, Bogota)
- Modular Hyprland configuration
- Waybar with glassmorphism design
- Wofi app launcher
- Dunst notifications
- Hyprlock and Hypridle
- Install script with NVIDIA auto-detection
- Complete documentation
