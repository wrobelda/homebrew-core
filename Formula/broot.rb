class Broot < Formula
  desc "New way to see and navigate directory trees"
  homepage "https://dystroy.org/broot"
  url "https://github.com/Canop/broot/archive/v0.13.5.tar.gz"
  sha256 "9c62ff8fefc5999a07ba8c16158fe0d574ec6cbe7b359d405b17d6fa97bad73c"
  head "https://github.com/Canop/broot.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "021434c2352da97a183a70dbdf82ccca86eb46f552d8ec5dc1a127c95f1ae01f" => :catalina
    sha256 "f8565c22874e3afb0c525ff101939f5c03696f972710e8f3f81f003216a923ea" => :mojave
    sha256 "1d029f5e322b1516ecda366e1265a5e86a4088400cc94ea506097690db95abf4" => :high_sierra
  end

  depends_on "rust" => :build

  uses_from_macos "zlib"

  def install
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    assert_match "A tree explorer and a customizable launcher", shell_output("#{bin}/broot --help 2>&1")

    require "pty"
    require "io/console"
    PTY.spawn(bin/"broot", "--cmd", ":pt", "--no-style", "--out", testpath/"output.txt", :err => :out) do |r, w, pid|
      r.winsize = [20, 80] # broot dependency termimad requires width > 2
      w.write "n\r"
      assert_match "New Configuration file written in", r.read
      Process.wait(pid)
    end
    assert_equal 0, $CHILD_STATUS.exitstatus
  end
end
