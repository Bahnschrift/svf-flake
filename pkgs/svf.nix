{
  stdenv,
  lib,
  pkgs,
  llvm,
  z3,
}:

stdenv.mkDerivation {
  pname = "SVF";
  version = "3.3";

  src = pkgs.fetchFromGitHub {
    owner = "SVF-tools";
    repo = "SVF";
    rev = "SVF-3.3";
    hash = "sha256-CH6lft22YKfuXzZGdMYoBdbLGDQq0Hx8LGpmPQih4zo=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    git
    clang
    llvm
  ];

  buildInputs = [
    llvm
    z3
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DSVF_ENABLE_ASSERTIONS=true"
    "-DBUILD_SHARED_LIBS=ON"

    "-DCMAKE_INSTALL_BINDIR=bin"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  enableParallelBuilding = true;

  NIX_CFLAGS_COMPILE = [
    "-fexceptions"
  ];

  meta = {
    description = "Static Value-Flow Analysis Framework for Source Code ";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "wpa";
  };
}
