class Gnumeric < Formula
  desc "GNOME Spreadsheet Application"
  homepage "https://projects.gnome.org/gnumeric/"
  url "https://download.gnome.org/sources/gnumeric/1.12/gnumeric-1.12.43.tar.xz"
  sha256 "87c9abd6260cf29401fa1e0fcce374e8c7bcd1986608e4049f6037c9d32b5fd5"

  bottle do
    rebuild 1
    sha256 "915075749528bd3b0f31651fbdfac38a6e06134eea6ed99f97b7b777fba0f3ac" => :mojave
    sha256 "9c9e678a2d3f25b34c1896d197a7cd3a6da6207fee9b3a64a5f3526ed742bf1c" => :high_sierra
    sha256 "65ff2bf41de0d4b5665e619720cf045b00177f345ec80198d0190cf0a1c3f66b" => :sierra
  end

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "adwaita-icon-theme"
  depends_on "gettext"
  depends_on "goffice"
  depends_on "itstool"
  depends_on "libxml2"
  depends_on "rarian"

  def install
    # ensures that the files remain within the keg
    inreplace "component/Makefile.in",
              "GOFFICE_PLUGINS_DIR = @GOFFICE_PLUGINS_DIR@",
              "GOFFICE_PLUGINS_DIR = @libdir@/goffice/@GOFFICE_API_VER@/plugins/gnumeric"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-schemas-compile"
    system "make", "install"
  end

  def post_install
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
  end

  test do
    system bin/"gnumeric", "--version"
  end
end
