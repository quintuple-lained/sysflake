{
  devshell = {
    path = ./devshell;
    description = "A template for a devshell used by direnv and stuff";
    welcomeText =
      "don't forget to adjust the shell and do `echo 'use flake' > .envrc && direnv allow`";
  };

  rust = {
    path = ./rust;
    description = "A template for rust using naersk and rust overlay";
    welcomeText =
      "don't forget to do `echo 'use flake' > .envrc && direnv allow`";
  };

  zmk = {
    path = ./zmk;
    description =
      "A template for the zmk toolchain, basically i'm too lazy for a pastebin";
    welcomeText = ''
      don't forget to do `echo 'use flake' > .envrc && direnv allow`

      to setup west do `west init -l app/` followed by `west update` and `west zephyr-export`
    '';
  };
}
