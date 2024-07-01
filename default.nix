# This file was generated by the {rix} R package v0.7.1 on 2024-07-01
# with following call:
# >rix(r_ver = "b9014df496d5b68bf7c0145d0e9b0f529ce4f2a8",
#  > r_pkgs = NULL,
#  > system_pkgs = NULL,
#  > git_pkgs = NULL,
#  > local_pkgs = NULL,
#  > tex_pkgs = NULL,
#  > ide = c("other",
#  > "code",
#  > "radian",
#  > "rstudio",
#  > "rserver"),
#  > project_path = ".",
#  > overwrite = TRUE,
#  > print = FALSE,
#  > message_type = "simple",
#  > shell_hook = NULL)
# It uses nixpkgs' revision b9014df496d5b68bf7c0145d0e9b0f529ce4f2a8 for reproducibility purposes
# which will install R version latest.
# Report any issues to https://github.com/b-rodrigues/rix
let
 pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b9014df496d5b68bf7c0145d0e9b0f529ce4f2a8.tar.gz") {};
     
  system_packages = builtins.attrValues {
    inherit (pkgs) 
      R
      glibcLocales
      nix;
  };
  
in

pkgs.mkShell {
  LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then  "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
  LANG = "en_US.UTF-8";
   LC_ALL = "en_US.UTF-8";
   LC_TIME = "en_US.UTF-8";
   LC_MONETARY = "en_US.UTF-8";
   LC_PAPER = "en_US.UTF-8";
   LC_MEASUREMENT = "en_US.UTF-8";

  buildInputs = [    system_packages   ];
  
}
