with import <nixpkgs> {};

let llvm = llvmPackages_16.llvm; in
let clang = clang_16; in
let go = pkgs.callPackage ./binary.nix {
    version = "1.18";
    # Use `print-hashes.sh ${version}` to generate the list below
    hashes = {
        darwin-amd64 = "70bb4a066997535e346c8bfa3e0dfe250d61100b17ccc5676274642447834969";
        darwin-arm64 = "9cab6123af9ffade905525d79fc9ee76651e716c85f1f215872b5f2976782480";
        linux-386 = "1c04cf4440b323a66328e0df95d409f955b9b475e58eae235fdd3d1f1cf02f4f";
        linux-amd64 = "e85278e98f57cdb150fe8409e6e5df5343ecb13cebf03a5d5ff12bd55a80264f";
        linux-arm64 = "7ac7b396a691e588c5fb57687759e6c4db84a2a3bbebb0765f4b38e5b1c5b00e";
        linux-armv6l = "a80fa43d1f4575fb030adbfbaa94acd860c6847820764eecb06c63b7c103612b";
        linux-ppc64le = "070351edac192483c074b38d08ec19251a83f8210765a532a84c3dcf8aec04d8";
        linux-s390x = "ea265f5e62fcaf941d53f0cdb81222d9668e1672a0d39d992f16ff0e87c0ee6b";
    };
}; in
llvmPackages_16.stdenv.mkDerivation {
  pname = "tinygo";
  version = "0.30.0";

  checkInputs = [ binaryen ];
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ llvmPackages_16.llvm clang_16.cc llvmPackages_16.bintools-unwrapped go ];

  ldflags = [ "-X github.com/tinygo-org/tinygo/goenv.TINYGOROOT=~/.tinygo" ];

  # Output contains static libraries for different arm cpus
  # and stripping could mess up these so only strip the compiler
  stripDebugList = [ "bin" ];

  shellHook = ''
    export LIBCLANG_PATH="${pkgs.llvmPackages.libclang}/lib";
  '';

  #LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [ llvmPackages_16.llvm llvmPackages_16.libclang ];
  LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [ llvmPackages_16.libllvm llvmPackages_16.libclang llvmPackages_16.stdenv ];

}
