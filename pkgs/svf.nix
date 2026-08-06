{
  stdenv,
  lib,
  pkgs,
  llvm,
  z3,
}:

stdenv.mkDerivation {
  pname = "SVF";
  version = "unstable-2026-08-06";

  src = pkgs.fetchFromGitHub {
    owner = "SVF-tools";
    repo = "SVF";
    rev = "18fb5650600530a54f0afc22f4df1a10b03d3c02";
    hash = "sha256-LizB76xhB74WRB/98ClGZ8VoV3EtfJgtfMvfbrlzd4k=";
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
