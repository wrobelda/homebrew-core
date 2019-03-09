class Kismet < Formula
  desc "Github mirror of official Kismet repository"
  homepage "https://www.kismetwireless.net"
  url "https://github.com/kismetwireless/kismet/archive/kismet-2019-01-beta2.tar.gz"
  sha256 "6ef3e1132468c3ec5b699cec2ee003f47bb6b21d1eeb71317fbac44ae33c3920"
  version "2019-01-beta2"
  head "https://github.com/kismetwireless/kismet.git"
  depends_on "pkg-config" => :build
  depends_on "libmicrohttpd"
  depends_on "pcre"
  depends_on "protobuf"
  depends_on "protobuf-c"

  def install
    ENV["CFLAGS"]=ENV["CPPFLAGS"]="-I/opt/local/include"
    ENV["LDFLAGS"]="-L=/opt/local/lib"

    inreplace "Makefile.in" do |s|
      s.gsub! "-o $(INSTUSR) -g $(SUIDGROUP)", ""
      s.gsub! "-o $(INSTUSR) -g $(INSTGRP)", ""
    end

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-libusb",
                          "--disable-python-tools"

    system "make", "install"
  end

  def caveats; <<-EOS
    Read http://www.kismetwireless.net/documentation.shtml and edit
      #{etc}/kismet.conf as needed.

    * SUID Root functionality does not work, you will have to run this as
      root, e.g. via `sudo`. Do so at your own risk.
    * Python tools are currently disabled to simplify the installation script.
      Feel free to co fix this.
    * This version can be configured interactively when it is run (listen
      interface, etc).
    * You may add the line "ncsource=en1:name=AirPort" to kismet.conf to avoid
      prompting at startup (assuming en1 is your AirPort card).
  EOS
  end

  test do
    system bin/"kismet", "-v --debug"
  end
end
