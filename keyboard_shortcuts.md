Run `mise run macos-defaults` to restore the keyboard shortcut and function-key settings below on a new machine. It imports `macos/symbolichotkeys.plist` (a full export of `com.apple.symbolichotkeys`, captured from a live-configured machine — covers the unbind below plus Launchpad/Mission Control/Keyboard/Input Sources/Screenshots/Services/Accessibility all being disabled except "Move focus to next window") and sets `com.apple.keyboard.fnState` (Use F1 etc. as standard function keys). Log out and back in afterward for the symbolic hotkey changes to take effect.

Caps-lock-to-Escape is handled by Karabiner-Elements (`home/.config/karabiner/karabiner.json`, `simple_modifications`). Karabiner writes its own mapping into the same underlying macOS Modifier Keys setting on startup, so System Settings > Keyboard > Keyboard Shortcuts > Modifier Keys correctly displays "Escape" — but it's a reflection of Karabiner's config, not the source of truth. Editing it directly in the GUI doesn't persist, since Karabiner overwrites it again the next time its daemon starts. Keep the remap in Karabiner's config, not the GUI.

Not automated — still manual per machine:

* On the Keyboardio/UHK, Caps-lock-to-Escape likely lives in the keyboard's own firmware (Chrysalis/UHK Agent) rather than macOS or Karabiner, so it already travels with the hardware and needs no action here.
