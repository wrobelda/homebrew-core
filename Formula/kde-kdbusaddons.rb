class KdeKdbusaddons < Formula
  desc "Addons to QtDBus"
  homepage "https://api.kde.org/frameworks/kdbusaddons/html/index.html"
  url "https://download.kde.org/stable/frameworks/5.79/kdbusaddons-5.79.0.tar.xz"
  sha256 "2071c5a06226b77c4cb1d4e46b50258c980e57448fdbb1a49259db64a7a2539f"
  license all_of: [
    "LGPL-2.0-only",
    "LGPL-2.0-or-later",
    any_of: ["LGPL-2.1-only", "LGPL-3.0-only"],
  ]
  head "https://invent.kde.org/frameworks/kdbusaddons.git"

  depends_on "cmake" => [:build, :test]
  depends_on "doxygen" => :build
  depends_on "graphviz" => :build
  depends_on "kde-extra-cmake-modules" => [:build, :test]
  depends_on "ninja" => :build

  depends_on "dbus"
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
    args << "-DQt5Test_DIR=#{Formula["qt@5"].opt_lib/"cmake/Qt5Test"}"

    system "cmake", testpath.to_s, *args
    system "cmake"
  end
end
