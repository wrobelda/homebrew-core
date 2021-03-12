class KdeKguiaddons < Formula
  desc "Addons to QtGui"
  homepage "https://api.kde.org/frameworks/kguiaddons/html/index.html"
  url "https://download.kde.org/stable/frameworks/5.79/kguiaddons-5.79.0.tar.xz"
  sha256 "bc00488e123a1f7905682393b140b80c8340cb131cc0baa3fb6ad575878f1c85"
  license all_of: [
    "LGPL-2.0-only",
    "LGPL-2.0-or-later",
    { any_of: ["GPL-2.0-only", "GPL-3.0-only"] },
    { any_of: ["LGPL-2.1-only", "LGPL-3.0-only"] },
  ]
  head "https://invent.kde.org/frameworks/kguiaddons.git"

  depends_on "cmake" => [:build, :test]
  depends_on "doxygen" => :build
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

    args << "-DWITH_WAYLAND=OFF"

    mkdir "build" do
      system "cmake", "..", "-G", "Ninja", *args
      system "ninja"
      system "ninja", "install"
      prefix.install "install_manifest.txt"
    end

    pkgshare.install "autotests"
    pkgshare.install "tests"
  end

  test do
    (testpath/"CMakeLists.txt").write <<~EOS
      include(FeatureSummary)
      find_package(ECM NO_MODULE)
      set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} "#{pkgshare}/cmake")

      add_subdirectory(autotests)
      add_subdirectory(tests)
    EOS

    cp_r (pkgshare/"autotests"), testpath
    cp_r (pkgshare/"tests"), testpath

    args = std_cmake_args
    args << "-DQt5_DIR=#{Formula["qt@5"].opt_lib/"cmake/Qt5"}"

    system "cmake", testpath.to_s, *args
    system "cmake"
  end
end
