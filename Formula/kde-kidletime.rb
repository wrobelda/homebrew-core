class KdeKidletime < Formula
  desc "Monitoring user activity"
  homepage "https://api.kde.org/frameworks/kidletime/html/index.html"
  url "https://download.kde.org/stable/frameworks/5.79/kidletime-5.79.0.tar.xz"
  sha256 "53e59c7f8465753f58d23543a1bc25f83ed9f0cd6381a800f9cff7cd488ce25e"
  license all_of: [
    "GPL-2.0-or-later",
    "LGPL-2.0-only",
    "MIT",
  ]
  head "https://invent.kde.org/frameworks/kidletime.git"

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

    mkdir "build" do
      system "cmake", "..", "-G", "Ninja", *args
      system "ninja"
      system "ninja", "install"
      prefix.install "install_manifest.txt"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write <<~EOS
      project(test_KF5IdleTime)
      find_package(Qt5 REQUIRED Core)
      find_package(KF5IdleTime REQUIRED)
    EOS

    args = std_cmake_args
    args << "-DQt5_DIR=#{Formula["qt@5"].opt_prefix/"lib/cmake/Qt5"}"
    system "cmake", testpath.to_s, *args
    system "make"
  end
end
