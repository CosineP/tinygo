with import <nixpkgs> {};

let llvm = llvmPackages_16.llvm; in
let clang = clang_16; in
pkgs.stdenv.mkDerivation {
  pname = "tinygo";
  version = "0.30.0";

  checkInputs = [ binaryen ];
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ llvmPackages_16.llvm clang_16.cc llvmPackages_16.bintools-unwrapped go_1_18 ];

  ldflags = [ "-X github.com/tinygo-org/tinygo/goenv.TINYGOROOT=~/.tinygo" ];

  # Output contains static libraries for different arm cpus
  # and stripping could mess up these so only strip the compiler
  stripDebugList = [ "bin" ];

  LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [ llvmPackages_16.llvm llvmPackages_16.libclang ];

}
