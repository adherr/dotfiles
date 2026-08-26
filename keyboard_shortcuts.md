Run `mise run macos-defaults` to restore the keyboard shortcut and function-key settings below on a new machine. It imports `macos/symbolichotkeys.plist` (a full export of `com.apple.symbolichotkeys`, captured from a live-configured machine — covers the unbind below plus Launchpad/Mission Control/Keyboard/Input Sources/Screenshots/Services/Accessibility all being disabled except "Move focus to next window") and sets `com.apple.keyboard.fnState` (Use F1 etc. as standard function keys). Log out and back in afterward for the symbolic hotkey changes to take effect.

Not automated — still manual per machine:

* Caps-lock-to-Escape, under Keyboard > Modifier Keys for each keyboard. No portable macOS default found for this; on the Keyboardio/UHK it likely lives in the keyboard's own firmware (Chrysalis/UHK Agent) rather than macOS at all, so it already travels with the hardware. Only the MacBook's built-in keyboard needs this set by hand on each machine.
