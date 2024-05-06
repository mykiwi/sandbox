# https://devenv.sh
# https://devenv.sh/reference/options/

{ pkgs, lib, config, inputs, ... }:

{
  enterShell = ''
    export PATH="$DEVENV_ROOT/tools/vendor/bin:$PATH"
    sh -c 'cd tools/.composer-home && make' > /dev/null
    devenv info
  '';

  env.COMPOSER_HOME = "${config.env.DEVENV_ROOT}/tools/.composer-home";
  env.COMPOSER_MEMORY_LIMIT = "-1";

  # devenv
  scripts.dec.exec      = "rm -rf .devenv .direnv .devenv.flake.nix";
  scripts.logs.exec     = "tail -f $DEVENV_DOTFILE/processes.log";
  scripts.up.exec       = "devenv processes up";
  scripts.upd.exec      = "devenv processes up --detach";
  scripts.down.exec     = "devenv processes down";
  # http-request-collections
  scripts.bruno.exec = "bunx @usebruno/cli@1.14 $@";
  # tools
  scripts.c.exec = "castor $@";
  # applications
  scripts.ddev.exec = "XDEBUG_MODE=debug XDEBUG_SESSION=1 dev";
  scripts.dev.exec  = "APP_ENV=dev  $DEVENV_ROOT/application/bin/console $@";
  scripts.prod.exec = "APP_ENV=prod $DEVENV_ROOT/application/bin/console $@";
  scripts.cc.exec   = "rm -rf DEVENV_ROOT/application/var/cache/* && dev cache:warmup";

  packages = [
    pkgs.bun
    pkgs.git
    pkgs.gnumake42
  ];

  languages.nix.enable = true;

  languages.php = { # cf https://github.com/cachix/devenv/blob/main/examples/caddy-php/devenv.nix
    enable = true;
    version = "8.3";
    extensions = [ "apcu" "xdebug" ];
    ini = ''
      memory_limit = 256M
    '';
    fpm.pools.web = {
      settings = {
        "pm" = "dynamic";
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 5;
      };
    };
  };

  services.caddy.enable = true; # cf https://github.com/cachix/devenv/blob/main/examples/mkcert/devenv.nix
  services.caddy.virtualHosts.":8000" = {
    extraConfig = ''
      root * application/public
      php_fastcgi unix/${config.languages.php.fpm.pools.web.socket}
      file_server
    '';
  };

  services.postgres = { # cf https://github.com/cachix/devenv/blob/main/examples/postgres-timescale/devenv.nix
    enable = true;
    package = pkgs.postgresql_16;
  };
}
