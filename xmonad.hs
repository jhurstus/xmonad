import XMonad
import XMonad.Actions.Plane
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Circle
import XMonad.Layout.Fullscreen
import XMonad.Layout.Grid
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.Util.EZConfig
import XMonad.Util.Run
import qualified XMonad.StackSet as W
import System.IO

defaultLayouts = smartBorders(avoidStruts(
  toggleLayouts (noBorders Full) (
  ResizableTall 1 (3/100) (1/2) []
  ||| Mirror (ResizableTall 1 (3/100) (1/2) [])
  ||| Grid
  ||| ThreeColMid 1 (3/100) (3/4)
  ||| Circle)))

myLayouts = defaultLayouts

myKeyBindings =
  [
    ((mod1Mask, xK_b), sendMessage ToggleStruts)
    , ((mod1Mask, xK_a), sendMessage MirrorShrink)
    , ((mod1Mask, xK_z), sendMessage MirrorExpand)
    , ((mod1Mask, xK_p), spawn "dmenu_run -fn \"Inconsolata-11\" -i -p \">\" -nb \"#002b36\" -nf \"#839496\" -sb \"#859900\" -sf \"#002b36\"")
    , ((mod1Mask, xK_u), focusUrgent)
    , ((mod1Mask .|. controlMask, xK_space), sendMessage (Toggle "Full"))
    , ((mod1Mask .|. controlMask, xK_l), spawn "gnome-screensaver-command -l")
    , ((mod1Mask, xK_f), spawn "firefox")
    , ((mod1Mask, xK_g), spawn "google-chrome")
    , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
    , ((0, xK_Print), spawn "scrot")
    , ((0, 0x1008FF12), spawn "~/.xmonad/bin/mute")
    , ((0, 0x1008FF11), spawn "amixer -q -D pulse sset Master 5%-")
    , ((0, 0x1008FF13), spawn "amixer -q -D pulse sset Master 5%+")
    , ((mod1Mask, xK_s), spawn "~/.xmonad/bin/toggleaudio")
    , ((mod1Mask .|. shiftMask, xK_F12), spawn "dbus-send --system --print-reply --dest=\"org.freedesktop.ConsoleKit\" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop")
    , ((mod1Mask .|. shiftMask, xK_F11), spawn "dbus-send --system --print-reply --dest=\"org.freedesktop.ConsoleKit\" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart")
  ]

myManagementHooks :: [ManageHook]
myManagementHooks = [
  (className =? "Gimp-2.8") --> doF (W.shift "9:Pix")
  ]

main = do
  spawn "xsetroot -solid '#002b36'"
  xmproc <- spawnPipe "~/.xmonad/bin/xmobar ~/.xmonad/xmobarrc"
  xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig {
    focusedBorderColor = "#cb4b16"
  , normalBorderColor = "#93a1a1"
  , borderWidth = 2
  , layoutHook = myLayouts
  , handleEventHook = docksEventHook <+> fullscreenEventHook
  , manageHook = manageHook defaultConfig
      <+> composeAll myManagementHooks
      <+> manageDocks
  , logHook = takeTopFocus >> dynamicLogWithPP (xmobarPP
    { ppOutput = hPutStrLn xmproc
    , ppTitle = xmobarColor "#839496" "" . shorten 80
    , ppCurrent = xmobarColor "#2aa198" "" . wrap "[" "]"
    , ppVisible = xmobarColor "#268bd2" "" . wrap "(" ")"
    , ppUrgent = xmobarColor "#cb4b16" "" . wrap "{" "}"
    })
  } `additionalKeys` myKeyBindings
