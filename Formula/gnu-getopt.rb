class GnuGetopt < Formula
  desc "Command-line option parsing library"
  homepage "http://frodo.looijaard.name/project/getopt"
  url "http://frodo.looijaard.name/system/files/software/getopt/getopt-1.1.6.tar.gz"
  mirror "https://distfiles.macports.org/getopt/getopt-1.1.6.tar.gz"
  mirror "https://fossies.org/linux/misc/getopt-1.1.6.tar.gz"
  sha256 "d0bf1dc642a993e7388a1cddfb9409bed375c21d5278056ccca3a0acd09dc5fe"

  bottle do
    sha256 "e905a353b1ef1688e569ee28f5caa35bbfa6a4b99f044e255087d0a8adbe092a" => :mojave
    sha256 "5dc8b07eb3425e5b57d7deb4dea187fc992ef358c9c053d3a2dc230d748b4252" => :high_sierra
    sha256 "05391b0dd0876ead74b18a4c5bb9c7db996586bf6918bd014db534027fd9ae2a" => :sierra
    sha256 "5e9e87fe18c5681e80f1cf940fed275ed895831304326bc5e7be6fb6e53e8594" => :el_capitan
    sha256 "f8dbbec03aaaeb1bc774d9bf606701901cc9a8ad15cecc5473567e51845057e6" => :yosemite
    sha256 "27938c615808c8e4ff2eacac0a4059c76dee5518a5c8bbfb304b24b70736b429" => :mavericks
  end

  keg_only :provided_by_macos

  depends_on "gettext"

  def install
    inreplace "Makefile" do |s|
      gettext = Formula["gettext"]
      s.change_make_var! "CPPFLAGS", "\\1 -I#{gettext.include}"
      s.change_make_var! "LDFLAGS", "\\1 -L#{gettext.lib} -lintl"
    end
    system "make", "prefix=#{prefix}", "mandir=#{man}", "install"
  end

  test do
    system "#{bin}/getopt", "-o", "--test"
  end
end
