class ApacheArrowGlib < Formula
  desc "GLib bindings for Apache Arrow"
  homepage "https://arrow.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=arrow/arrow-0.12.1/apache-arrow-0.12.1.tar.gz"
  sha256 "e93e43343544e344bbc912b89da01d8abf66596f029d26b2b135b102a9e39895"

  bottle do
    sha256 "930d5249652eddc1ccae438a2353a08b5ce18231edd2e42e16982e3d84cccc66" => :mojave
    sha256 "96a41fd90da27750a9f4abdbb0b0cd127db04807831001a4ca14751ebeb6c576" => :high_sierra
    sha256 "56acc7a8804e5c2828ba71204001b306dd8666f7c38afd45134b00a4c00af22c" => :sierra
  end

  depends_on "gobject-introspection" => :build
  depends_on "pkg-config" => :build
  depends_on "apache-arrow"
  depends_on "glib"

  def install
    cd "c_glib" do
      system "./configure", "--prefix=#{prefix}"
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~SOURCE
      #include <arrow-glib/arrow-glib.h>
      int main(void) {
        GArrowNullArray *array = garrow_null_array_new(10);
        g_object_unref(array);
        return 0;
      }
    SOURCE
    apache_arrow = Formula["apache-arrow"]
    glib = Formula["glib"]
    flags = %W[
      -I#{include}
      -I#{apache_arrow.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -L#{lib}
      -L#{apache_arrow.opt_lib}
      -L#{glib.opt_lib}
      -DNDEBUG
      -larrow-glib
      -larrow
      -lglib-2.0
      -lgobject-2.0
      -lgio-2.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
