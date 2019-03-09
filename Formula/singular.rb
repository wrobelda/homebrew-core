class Singular < Formula
  desc "Computer algebra system for polynomial computations"
  homepage "https://www.singular.uni-kl.de/"
  url "https://www.mathematik.uni-kl.de/ftp/pub/Math/Singular/SOURCES/4-1-1/singular-4.1.1p4.tar.gz"
  version "4.1.1p4"
  sha256 "79d6ed8489ef08eed4d4f4b8f8be4ab4da70f611e0b8889fdc6f825f25981a84"

  bottle do
    sha256 "7c3a5b416a29576bcff523b4ca9ba2eab2e33ba239f52403dfb2561bb0ab47fd" => :mojave
    sha256 "52213af26995625db95a5d0c440bba6cdff5edec858baefff5de1b71a3705e84" => :high_sierra
    sha256 "8832f44be358f6f939268a1e0da3af43260e207f103186e21949702bd2c04848" => :sierra
  end

  head do
    url "https://github.com/Singular/Sources.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "gmp"
  depends_on "mpfr"
  depends_on "ntl"

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "CXXFLAGS=-std=c++11"
    system "make", "install"
  end

  test do
    testinput = <<~EOS
      ring r = 0,(x,y,z),dp;
      poly p = x;
      poly q = y;
      poly qq = z;
      p*q*qq;
    EOS
    assert_match "xyz", pipe_output("#{bin}/Singular", testinput, 0)
  end
end
