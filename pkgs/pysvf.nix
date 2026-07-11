{
  lib,
  fetchFromGitHub,

  python3Packages,
  cmake,
  ninja,

  llvm,
  z3,
  svf,

  patchelf,
  autoPatchelfHook,
}:

python3Packages.buildPythonPackage {
  pname = "pysvf";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SVF-tools";
    repo = "SVF-Python";
    rev = "d5cc9525b77e11053cb04dc10eb4d7f2706c6814";
    hash = "sha256-yE7OvFccR5KGfBGwzf4E1haKH1nYkD7Ow+edv6r56T4=";
  };

  pyproject = true;

  build-system = with python3Packages; [
    setuptools
  ];

  nativeBuildInputs = [
    cmake
    ninja
    python3Packages.pybind11
    patchelf
    autoPatchelfHook
  ];

  buildInputs = [
    llvm
    z3.lib
    z3
    svf
  ];

  dontUseCmakeConfigure = true;

  preBuild = ''
    export SVF_DIR=${svf}
    export LLVM_DIR=${llvm.dev}/lib/cmake/llvm

    # SVF-Python's setup.py hardcodes "$Z3_DIR/bin/libz3.so" as both the
    # vendored runtime dependency path (patchelf --add-needed
    # $ORIGIN/SVF/z3.obj/bin/libz3.so) and the source it copies from. nixpkgs'
    # z3 has split outputs with no "bin/libz3.so", so build a directory with
    # the layout it expects.
    mkdir -p z3-dir/bin z3-dir/lib
    for f in ${z3.lib}/lib/*; do
        ln -s "$f" z3-dir/bin/"$(basename "$f")"
        ln -s "$f" z3-dir/lib/"$(basename "$f")"
    done
    ln -s ${z3.dev}/include z3-dir/include
    export Z3_DIR=$PWD/z3-dir

    export PYBIND11_DIR=$(${python3Packages.python}/bin/python -m pybind11 --cmakedir)
  '';

  preFixup = ''
    find "$out" -type f \( -name '*.so*' -o -perm -111 \) | while read -r f; do
      if rpath=$(patchelf --print-rpath "$f" 2>/dev/null); then
        newrpath=$(echo "$rpath" | tr ':' '\n' | grep -v '^/build' | paste -sd: -)
        if [ "$rpath" != "$newrpath" ]; then
          echo "stripping /build rpath entries from $f"
          patchelf --set-rpath "$newrpath" "$f"
        fi
      fi
    done
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Python bindings for SVF";
    homepage = "https://github.com/SVF-tools/SVF-Python";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
  };
}
