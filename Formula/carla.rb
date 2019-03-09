class Carla < Formula
  desc "Audio plugin host supporting LADSPA, LV2, VST2/3, SF2 and more"
  homepage "https://kxstudio.linuxaudio.org/Applications:Carla"
  url "https://github.com/falkTX/Carla/archive/v1.9.13.tar.gz"
  sha256 "cc6639dd23b22279f8ab1ae9b51e71d5480b86112c475110daa68cf68fb8cf63"
  revision 1
  head "https://github.com/falkTX/Carla.git"

  bottle do
    cellar :any
    sha256 "7c7bfc02681d230a88fb382f099808e446f871a587af5970c7739a58fd6be77a" => :mojave
    sha256 "d17f98134588c6bba57c1731fb0018e136016ada2d4f00d8555b20b0701c1ee4" => :high_sierra
    sha256 "74a55831b1cdcafcfa758475aee7d75c60e156b09bff81abe5c0656a3687c9de" => :sierra
  end

  depends_on "pkg-config" => :build
  depends_on "fluid-synth"
  depends_on "liblo"
  depends_on "libmagic"
  depends_on "pyqt"
  depends_on "python"

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system bin/"carla", "--version"
    system lib/"carla/carla-discovery-native", "internal", ":all"
  end
end
