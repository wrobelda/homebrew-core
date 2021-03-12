class KdeSyntaxHighlighting < Formula
  desc "Syntax highlighting engine for structured text and code"
  homepage "https://api.kde.org/frameworks/syntax-highlighting/html/index.html"
  url "https://download.kde.org/stable/frameworks/5.79/syntax-highlighting-5.79.1.tar.xz"
  sha256 "b2825ebee4c527f96562d18abb553195809dcc32174a4b998c71850e24527990"
  license all_of: [
    "GPL-2.0-only",
    "LGPL-2.0-only",
    "LGPL-2.0-or-later",
    "LGPL-2.1-or-later",
    "MIT",
  ]
  head "https://invent.kde.org/frameworks/syntax-highlighting.git"

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
      project(test_KF5SyntaxHighlighting)
      find_package(Qt5 REQUIRED Core Gui)
      find_package(KF5SyntaxHighlighting REQUIRED)
    EOS

    args = std_cmake_args
    args << "-DQt5_DIR=#{Formula["qt@5"].opt_prefix/"lib/cmake/Qt5"}"
    system "cmake", testpath.to_s, *args
    system "make"
  end
end
