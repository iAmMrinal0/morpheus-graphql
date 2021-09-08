args@{ program ? "morpheus-graphql", ... }:

let
  nixpkgs = builtins.fetchTarball {
    # commit from Aug 18th 2021, release-21.05
    url =
      "https://github.com/NixOS/nixpkgs/archive/7bbca9877caed472c6b5866ea09302cfcdce3dbf.tar.gz";
    sha256 = "1byrw1inwrlw7yp5dwvdf0zv1zdqnjq32j1j7cmlwah4x7f46bvg";
  };
  pkgs = import nixpkgs {
           config.allowUnfree = true;
         };
  ghc = "ghc8104";
in with pkgs;
let
  ghcCompiler = haskell.compiler.${ghc};
  ghcHaskellPkgs = haskell.packages.${ghc};
  exe = haskell.lib.justStaticExecutables;

  mkPackage = self: pkg: path: inShell:
    let orig = self.callCabal2nix pkg path { };
    in if inShell
    # Avoid copying the source directory to nix store by using
    # src = null.
    then
      orig.overrideAttrs (oldAttrs: { src = null; })
    else
      orig;

  kronorPkgs = inShell:
    ghcHaskellPkgs.override {
      overrides = self: super: {
        morpheus-graphql = mkPackage self "morpheus-graphql" ./. inShell;
        morpheus-graphql-app = haskell.lib.dontCheck (mkPackage self "morpheus-graphql-app" ./morpheus-graphql-app false);
        morpheus-graphql-core = mkPackage self "morpheus-graphql-core" ./morpheus-graphql-core false;
        morpheus-graphql-code-gen = mkPackage self "morpheus-graphql-code-gen" ./morpheus-graphql-code-gen false;
        morpheus-graphql-tests = mkPackage self "morpheus-graphql-tests" ./morpheus-graphql-tests false;
        morpheus-graphql-subscriptions = mkPackage self "morpheus-graphql-subscriptions" ./morpheus-graphql-subscriptions false;
        morpheus-graphql-examples-servant = mkPackage self "morpheus-graphql-examples-servant" ./morpheus-graphql-examples-servant false;
      };
    };

  shell = (kronorPkgs true).shellFor {
    withHoogle = true;
    packages = p: [
      p.morpheus-graphql
      p.morpheus-graphql-app
      p.morpheus-graphql-core
      # p.morpheus-graphql-code-gen
      # p.morpheus-graphql-tests
      p.morpheus-graphql-subscriptions
      p.morpheus-graphql-examples-servant
    ];
    passthru.pkgs = pkgs;
    src = null; # pkgs.nix-gitignore.gitignoreSource [] ./.;
    nativeBuildInputs = with ghcHaskellPkgs; [
      (exe cabal-install)
      hpack
      haskell-language-server
      ghcid

      pkgs.dhall
      pkgs.dhall-json
      pkgs.dhall-lsp-server

      pkgs.autoconf
      pkgs.automake
      pkgs.m4
      pkgs.lorri
      pkgs.jwt-cli
      pkgs.parallel
      pkgs.expect
    ];
    buildInputs = [ pkgs.zlib ];
  };
in {
  # Pass the kronor* program to be built, defaults to `kronor`
  # We don't need profiled builds when we want to build the project
  morpheus-graphql =
    haskell.lib.disableLibraryProfiling (exe (kronorPkgs false)."${program}");
  shell = shell;
}
