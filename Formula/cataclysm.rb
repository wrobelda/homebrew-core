class Cataclysm < Formula
  desc "Fork/variant of Cataclysm Roguelike"
  homepage "https://github.com/CleverRaven/Cataclysm-DDA"
  url "https://github.com/CleverRaven/Cataclysm-DDA/archive/0.D.tar.gz"
  version "0.D"
  sha256 "6cc97b3e1e466b8585e8433a6d6010931e9a073f6ec060113161b38052d82882"
  head "https://github.com/CleverRaven/Cataclysm-DDA.git"

  bottle do
    cellar :any
    sha256 "9eddd3fb35b4090e7e3db1d9d0d11226b65a16b00ab0a803ecc038bf5597ca0f" => :mojave
    sha256 "2dd7702becd712c2f3f6c1e2683a3dc8e08644204f039c6a4339c1930fed4f2c" => :high_sierra
    sha256 "978296d8abe4f25b88afc7df8e3914335e417e7fb44cc2625900101ef91a8b74" => :sierra
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "lua"
  depends_on "sdl2"
  depends_on "sdl2_image"
  depends_on "sdl2_mixer"
  depends_on "sdl2_ttf"

  def install
    ENV.cxx11

    args = %W[
      NATIVE=osx
      RELEASE=1
      OSX_MIN=#{MacOS.version}
      LUA=1
      USE_HOME_DIR=1
      TILES=1
      SOUND=1
    ]

    args << "CLANG=1" if ENV.compiler == :clang

    system "make", *args

    # no make install, so we have to do it ourselves
    libexec.install "cataclysm-tiles", "data", "gfx", "lua"

    inreplace "cataclysm-launcher" do |s|
      s.change_make_var! "DIR", libexec
    end
    bin.install "cataclysm-launcher" => "cataclysm"
  end

  test do
    # make user config directory
    user_config_dir = testpath/"Library/Application Support/Cataclysm/"
    user_config_dir.mkpath

    # run cataclysm for 5 seconds
    game = fork do
      system bin/"cataclysm"
    end

    sleep 5
    Process.kill("HUP", game)

    assert_predicate user_config_dir/"config",
                     :exist?, "User config directory should exist"
    assert_predicate user_config_dir/"templates",
                     :exist?, "User template directory should exist"
    assert_predicate user_config_dir/"save",
                     :exist?, "User save directory should exist"
  end
end
