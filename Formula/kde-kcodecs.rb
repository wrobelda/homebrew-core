class KdeKcodecs < Formula
  desc "String encoding library"
  homepage "https://api.kde.org/frameworks/kcodecs/html/index.html"
  url "https://download.kde.org/stable/frameworks/5.79/kcodecs-5.79.0.tar.xz"
  sha256 "c81fa7229cb70021339d4c822517980e30f0a9dc79f143f577a6d56dcd6f64a9"
  license all_of: [
    "BSD-3-Clause",
    "GPL-2.0-or-later",
    "LGPL-2.0-only",
    "LGPL-2.0-or-later",
    "LGPL-2.1-or-later",
    "MIT",
    "MPL-1.1",
  ]
  head "https://invent.kde.org/frameworks/kcodecs.git"

  depends_on "cmake" => [:build, :test]
  depends_on "doxygen" => :build
  depends_on "gperf" => :build
  depends_on "graphviz" => :build
  depends_on "kde-extra-cmake-modules" => [:build, :test]
  depends_on "ninja" => :build

  depends_on "qt@5"

  def install
    args = std_cmake_args
    args << "-D BUILD_QCH=ON"
    args << "-D BUILD_TESTING=OFF"
    args << "-D BUILD_TESTS=OFF"
    args << "-D BUILD_UNITTESTS=OFF"
    args << "-D CMAKE_INSTALL_BUNDLEDIR=#{bin}"
    args << "-D KDE_INSTALL_LIBDIR=lib"
    args << "-D KDE_INSTALL_PLUGINDIR=lib/qt5/plugins"
    args << "-D KDE_INSTALL_QMLDIR=lib/qt5/qml"
    args << "-D KDE_INSTALL_QTPLUGINDIR=lib/qt5/plugins"

    mkdir "build" do
      system "cmake", "..", "-G", "Ninja", *args
      system "ninja"
      system "ninja", "install"
      prefix.install "install_manifest.txt"
    end
    pkgshare.install "autotests"
  end

  test do
    (testpath/"CMakeLists.txt").write <<~EOS
      include(FeatureSummary)
      find_package(ECM NO_MODULE)
      set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} "#{pkgshare}/cmake")

      add_subdirectory(autotests)
    EOS

    cp_r (pkgshare/"autotests"), testpath

    args = std_cmake_args
    args << "-DQt5_DIR=#{Formula["qt@5"].opt_lib/"cmake/Qt5"}"

    system "cmake", testpath.to_s, *args
    system "make"
  end
end
