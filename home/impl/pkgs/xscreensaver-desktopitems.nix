# SPDX-FileCopyrightText: 2022 Noah Fontes
#
# SPDX-License-Identifier: CC-BY-NC-SA-4.0

{ libxml2
, runCommand
, xscreensaver
}:
runCommand
  "xscreensaver-desktop-items"
  {
    desktopItem = ''
      [Desktop Entry]
      Name=@name@
      Exec=@exec@ @arg@
      TryExec=@exec@
      Comment=@comment@
      StartupNotify=false
      Terminal=false
      Type=Application
      Categories=Screensaver;
      OnlyShowIn=MATE;
    '';
    passAsFile = [ "desktopItem" ];
  }
  ''
    mkdir -p $out/share/applications/screensavers
    for config in ${xscreensaver}/share/xscreensaver/config/*.xml; do
      local exec="${xscreensaver}/libexec/xscreensaver/$(${libxml2}/bin/xmllint --xpath 'string(/screensaver/@name)' $config)"
      local arg="$(${libxml2}/bin/xmllint --xpath 'string(/screensaver/command/@arg)' $config)"
      local name="$(${libxml2}/bin/xmllint --xpath 'string(/screensaver/@_label)' $config)"
      local comment="$(${libxml2}/bin/xmllint --xpath 'normalize-space(/screensaver/_description/text())' $config)"

      substitute $desktopItemPath "$out/share/applications/screensavers/xscreensaver-$(basename $config .xml).desktop" \
        --subst-var exec \
        --subst-var arg \
        --subst-var name \
        --subst-var comment
    done
  ''
