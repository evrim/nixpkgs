{ stdenv, fetchurl, lib, makeWrapper
, jdk
, gtk, glib
, libXtst
, git, mercurial, subversion
, which
}:

let
  the_version = "6_0_6";

in

stdenv.mkDerivation rec {
  name = "smartgithg-${the_version}";

  src = fetchurl {
    url = "http://www.syntevo.com/download/smartgithg/" +
          "smartgithg-generic-${the_version}.tar.gz";
    sha256 = "13e41560138ef18395fbe0bf56d4d29e8614eee004d51d7dd03381080d8426e6";
  };

  buildInputs = [
    makeWrapper
    jdk
  ];

  buildCommand = let
    pkg_path = "$out/${name}";
    bin_path = "$out/bin";
    runtime_paths = lib.makeSearchPath "bin" [
      jdk
      git mercurial subversion
      which
    ];
    runtime_lib_paths = lib.makeLibraryPath [
      gtk glib
      libXtst
    ];
  in ''
    tar xvzf $src
    mkdir -pv $out
    # unpacking should have produced a dir named ${name}
    cp -a ${name} $out
    mkdir -pv ${bin_path}
    makeWrapper ${pkg_path}/bin/smartgithg.sh ${bin_path}/smartgithg \
      --prefix PATH : ${runtime_paths} \
      --prefix LD_LIBRARY_PATH : ${runtime_lib_paths} \
      --prefix JDK_HOME : ${jdk}/lib/openjdk
    patchShebangs $out
  '';

  meta = with stdenv.lib; {
    description = "GUI for Git, Mercurial, Subversion";
    homepage = http://www.syntevo.com/smartgithg/;
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
