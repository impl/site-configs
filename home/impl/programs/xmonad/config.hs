-- SPDX-FileCopyrightText: 2021-2022 Noah Fontes
--
-- SPDX-License-Identifier: CC-BY-NC-SA-4.0

{-# LANGUAGE FlexibleContexts #-}

import Control.Monad
import Data.Map as M hiding (keys, map, mapMaybe)
import Data.Maybe
import System.IO
import XMonad
import XMonad.Actions.Submap
import XMonad.Actions.UpdatePointer
import XMonad.Config.Mate (mateConfig, mateRegister)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.RefocusLast
import XMonad.Layout.Decoration
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.TrackFloating
import XMonad.Layout.WindowNavigation
import qualified XMonad.StackSet as W
import qualified XMonad.Util.WindowState as WS

main :: IO()
main = xmonad . docks . ewmh $ def
  { handleEventHook = myEventHook <> handleEventHook def
  , keys = myKeys <> keys mateConfig
  , layoutHook = myLayoutHook $ layoutHook def
  , logHook = myLogHook <+> logHook def
  , manageHook = myManageHook <> manageHook def
  , modMask = mod4Mask
  , startupHook = mateRegister >> startupHook def
  , terminal = "@kitty@"
  }

myEventHook = refocusLastWhen (return True)

myKeys conf@(XConfig {modMask = mod}) = M.fromList $
  [ ((mod, xK_p), spawn "@rofi@ -font '@font@ @fontSize@' -modi drun,ssh,window -show drun -show-icons")

  , ((mod .|. shiftMask, xK_l), spawn "mate-screensaver-command --lock")

  , ((mod .|. controlMask, xK_h), sendMessage $ pullGroup L)
  , ((mod .|. controlMask, xK_l), sendMessage $ pullGroup R)
  , ((mod .|. controlMask, xK_k), sendMessage $ pullGroup U)
  , ((mod .|. controlMask, xK_j), sendMessage $ pullGroup D)
  , ((mod .|. controlMask, xK_m), withFocused (sendMessage . MergeAll))
  , ((mod .|. controlMask, xK_u), withFocused (sendMessage . UnMerge))
  , ((mod, xK_s), submap $ defaultSublMap conf)
  ]

myLayoutHook =
  avoidStruts .
  noBorders .
  refocusLastLayoutHook .
  trackFloating .
  windowNavigation .
  myLayout .
  mySpacing

myLayout :: (Eq a, LayoutModifier (Sublayout Simplest) a, LayoutClass l a) =>
  l a -> ModifiedLayout (Decoration TabbedDecoration DefaultShrinker)
                        (ModifiedLayout (Sublayout Simplest) l) a
myLayout outer = addTabsLeft shrinkText myTabbedTheme $ subLayout [] Simplest outer

mySpacing = spacingRaw False (Border 5 0 5 0) True (Border 0 5 0 5) True

myTabbedTheme = def
  { activeColor = "@activeColor@"
  , inactiveColor = "@inactiveColor@"
  , urgentColor = "@urgentColor@"
  , activeBorderWidth = 0
  , inactiveBorderWidth = 0
  , urgentBorderWidth = 0
  , activeTextColor = "@activeTextColor@"
  , inactiveTextColor = "@inactiveTextColor@"
  , fontName = "xft:@font@-@fontSize@"
  , decoHeight = 25
  , decoWidth = 150
  }

newtype MigrateWindowState = MigrateWindowState Window
  deriving (Read, Show)

myLogHook = mconcat
  [ myMigrateLogHook
  , updatePointer (0.5, 0.5) (0, 0)
  ]

myMigrateLogHook :: X ()
myMigrateLogHook = withWindowSet $ mconcat . map tryMigrate . W.allWindows
  where
    tryMigrate :: Window -> X ()
    tryMigrate newWindow = do
      req <- runGetStateQuery newWindow
      whenJust req $ \focusedWindow -> do
        runClearStateQuery newWindow
        migrate newWindow focusedWindow

    runGetStateQuery :: Window -> X (Maybe MigrateWindowState)
    runGetStateQuery = WS.runStateQuery WS.get

    runClearStateQuery :: Window -> X ()
    runClearStateQuery = WS.runStateQuery $ WS.put (Nothing :: Maybe MigrateWindowState)

    migrate newWindow (MigrateWindowState focusedWindow) = sendMessage $ Migrate newWindow focusedWindow

myManageHook = mconcat
  [ insertPosition End Newer
  , myMigrateManageHook $ className =? "kitty"
  ]

myMigrateManageHook :: Query Bool -> ManageHook
myMigrateManageHook query = do
  newWindow <- ask
  focusedWindow <- liftX $ gets (W.peek . windowset)
  let focusedQuery = fromMaybe (return False) $ flip local query <$> const <$> focusedWindow

  query <&&> focusedQuery --> do
    liftX $ WS.runStateQuery (WS.put $ MigrateWindowState <$> focusedWindow) newWindow
    mempty
