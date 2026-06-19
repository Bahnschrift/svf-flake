{
  stdenv,
  lib,
  pkgs,
  llvm,
  z3,
  svf,
}:

stdenv.mkDerivation {
  pname = "SVFIR";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "SVF-tools";
    repo = "Software-Security-Analysis";
    rev = "ee8ccdd22bc4efc6d124eeadfc5a1079acef01ea";
    hash = "sha256-4CTbQlei9gEuZvCSQASp4BhdDvJfyjToPCn9KS+oMqI=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    clang
    ninja
    git
  ];

  buildInputs = [
    llvm
    z3
  ];

  postPatch = ''
    sed -i \
      -e '/^add_subdirectory(HelloWorld)/d'      \
      -e '/^add_subdirectory(Lab-Exercise/d'     \
      -e '/^set(GTRAV_DIR/d'                     \
      -e '/^set(Z3MGR_DIR/d'                     \
      -e '/^add_subdirectory(Assignment-/d'       \
      CMakeLists.txt

      sed -i \
        '/SVF_ENABLE_RTTI.*STREQUAL.*LLVM_ENABLE_RTTI/c\    if((SVF_ENABLE_RTTI AND NOT LLVM_ENABLE_RTTI) OR (NOT SVF_ENABLE_RTTI AND LLVM_ENABLE_RTTI))' \
        CMakeLists.txt
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/svfir $out/bin/
  '';

  cmakeFlags = [
    "-DSVF_DIR=${svf}"
    "-DLLVM_DIR=${llvm.dev}/lib/cmake/llvm"
    "-DZ3_DIR=${z3.lib}"
  ];

  NIX_CFLAGS_COMPILE = [
    "-fexceptions"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "SVFIR tool: dumps PAG, ICFG, and ConstraintGraph from LLVM bitcode";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "svfir";
  };
}
