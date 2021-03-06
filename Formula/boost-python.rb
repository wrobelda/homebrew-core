class BoostPython < Formula
  desc "C++ library for C++/Python2 interoperability"
  homepage "https://www.boost.org/"
  url "https://dl.bintray.com/boostorg/release/1.74.0/source/boost_1_74_0.tar.bz2"
  mirror "https://dl.bintray.com/homebrew/mirror/boost_1_74_0.tar.bz2"
  sha256 "83bfc1507731a0906e387fc28b7ef5417d591429e51e788417fe9ff025e116b1"
  license "BSL-1.0"
  head "https://github.com/boostorg/boost.git"

  bottle do
    rebuild 1
    sha256 cellar: :any, big_sur:  "773bf09629cf60599cb4118827d40b81ef792efbe24796ac5a756e4c173ba889"
    sha256 cellar: :any, catalina: "6fb5b45ffb117fa0a996a24f6ccf8041685ebbe65b8a5cea26d92028eeff09e4"
    sha256 cellar: :any, mojave:   "f17e33b10753adb4d49cd1d9daf46ba28552953e53069025b84393cb5db89223"
  end

  deprecate! date: "2020-01-01", because: "uses Python 2, which is no longer supported"

  depends_on "boost"
  depends_on :macos # Due to Python 2

  def install
    # "layout" should be synchronized with boost
    args = %W[
      -d2
      -j#{ENV.make_jobs}
      --layout=tagged-1.66
      install
      threading=multi,single
      link=shared,static
    ]

    # Boost is using "clang++ -x c" to select C compiler which breaks C++14
    # handling using ENV.cxx14. Using "cxxflags" and "linkflags" still works.
    args << "cxxflags=-std=c++14"
    args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++" if ENV.compiler == :clang

    pyver = Language::Python.major_minor_version "python"

    system "./bootstrap.sh", "--prefix=#{prefix}", "--libdir=#{lib}",
                             "--with-libraries=python", "--with-python=python"

    system "./b2", "--build-dir=build-python",
                   "--stagedir=stage-python",
                   "--libdir=install-python/lib",
                   "--prefix=install-python",
                   "python=#{pyver}",
                   *args

    lib.install Dir["install-python/lib/*.*"]
    lib.install Dir["stage-python/lib/*py*"]
    doc.install Dir["libs/python/doc/*"]
  end

  def caveats
    <<~EOS
      This formula provides Boost.Python for Python 2. Due to a
      collision with boost-python3, the CMake Config files are not
      available. Please use -DBoost_NO_BOOST_CMAKE=ON when building
      with CMake or switch to Python 3.
    EOS
  end

  test do
    (testpath/"hello.cpp").write <<~EOS
      #include <boost/python.hpp>
      char const* greet() {
        return "Hello, world!";
      }
      BOOST_PYTHON_MODULE(hello)
      {
        boost::python::def("greet", greet);
      }
    EOS

    pyprefix = `python-config --prefix`.chomp
    pyincludes = Utils.popen_read("python-config", "--includes").chomp.split
    pylib = Utils.popen_read("python-config", "--ldflags").chomp.split

    system ENV.cxx, "-shared", "hello.cpp", "-L#{lib}", "-lboost_python27",
                    "-o", "hello.so", "-I#{pyprefix}/include/python2.7",
                    *pyincludes, *pylib

    output = <<~EOS
      from __future__ import print_function
      import hello
      print(hello.greet())
    EOS
    assert_match "Hello, world!", pipe_output("python", output, 0)
  end
end
