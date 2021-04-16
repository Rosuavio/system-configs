{ pkgs, ... }:
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
       swaylock
       swayidle
       xwayland
       wl-clipboard
       mako
       alacritty
       rxvt-unicode
       dmenu
    ];
  };
}
