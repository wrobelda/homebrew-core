class ThorsSerializer < Formula
  desc "Declarative serialization library (JSON/YAML) for C++"
  homepage "https://github.com/Loki-Astari/ThorsSerializer"
  url "https://github.com/Loki-Astari/ThorsSerializer.git",
      :tag      => "1.10.2",
      :revision => "163fb907e8a4e0c3e05b8e15c1fdf6e0a02ca2c9"

  bottle do
    cellar :any
    sha256 "1d8048082933af07d1f1bee47c9a2fcdbe05ff957e4c9a28b77b03273e0cd7a5" => :mojave
    sha256 "982da2ada17a8243dffab3e7dbcea9f22f8e7afed5782d5162ceb84b7c211775" => :high_sierra
    sha256 "edc16e04dc84c2ff96a5486f03d28626c837d5fcde960cf275f1062cc151ad8d" => :sierra
  end

  depends_on "libyaml"

  def install
    ENV["COV"] = "gcov"

    system "./configure", "--disable-binary",
                          "--disable-vera",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "ThorSerialize/JsonThor.h"
      #include "ThorSerialize/SerUtil.h"
      #include <sstream>
      #include <iostream>
      #include <string>

      struct Block
      {
          std::string             key;
          int                     code;
      };
      ThorsAnvil_MakeTrait(Block, key, code);

      int main()
      {
          using ThorsAnvil::Serialize::jsonImport;
          using ThorsAnvil::Serialize::jsonExport;

          std::stringstream   inputData(R"({"key":"XYZ","code":37373})");

          Block    object;
          inputData >> jsonImport(object);

          if (object.key != "XYZ" || object.code != 37373) {
              std::cerr << "Fail";
              return 1;
          }
          std::cerr << "OK";
          return 0;
      }
    EOS
    system ENV.cxx, "-std=c++14", "test.cpp", "-o", "test",
           "-I#{include}", "-L#{lib}", "-lThorSerialize17"
    system "./test"
  end
end
