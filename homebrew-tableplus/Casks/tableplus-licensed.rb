cask "tableplus-licensed" do
  version "520"
  sha256 "c5b740831175b016493428855fe0d5a60f1758623f82055e925ec2b05c914289"

  url "https://download.tableplus.com/macos/#{version}/TablePlus.dmg"
  name "TablePlus"
  desc "Pinned build 520 — matches an existing paid license; do not auto-update"
  homepage "https://tableplus.com/"

  auto_updates false
  depends_on macos: :big_sur

  app "TablePlus.app"

  postflight_steps do
    system_command "/usr/bin/defaults",
                   args: ["write", "com.tinyapp.TablePlus", "SUEnableAutomaticChecks", "-bool", "false"]
    system_command "/usr/bin/defaults",
                   args: ["write", "com.tinyapp.TablePlus", "ViewSetting", "-dict-add",
                          "IsDisableUpdateNotification", "-int", "1"]
  end

  zap trash: [
    "~/Library/Application Support/com.tinyapp.TablePlus",
    "~/Library/Preferences/com.tinyapp.TablePlus.plist",
    "~/Library/Saved Application State/com.tinyapp.TablePlus.savedState",
  ]
end
