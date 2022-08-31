{
  # Input Club (0x308f) WhiteFox - True Fox (0x000a) needs
  # HID_QUIRK_NO_INIT_REPORTS
  boot.extraModprobeConfig = ''
    options usbhid quirks=0x308f:0x000a:0x20000000
  '';
}
