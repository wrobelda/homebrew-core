require "language/node"

class Svgo < Formula
  desc "Nodejs-based tool for optimizing SVG vector graphics files"
  homepage "https://github.com/svg/svgo"
  url "https://github.com/svg/svgo/archive/1.2.0.tar.gz"
  sha256 "ff832bc1dd2dd6f01638b57f288539df7be2a26bb0d941e0d911f974f66286a1"

  bottle do
    cellar :any_skip_relocation
    sha256 "cba3a6b0a6f572186efa9fb3d8f27f884d7527f2f0d9490c7220297f69c18813" => :mojave
    sha256 "6e29dbbfef143135466a6a4d0926944acdd13a8410f6f7209d2ac90641224738" => :high_sierra
    sha256 "b4fdade15b336b801f0bd862f05c1407f851f6203cbe82bd4e87966778035a68" => :sierra
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    cp test_fixtures("test.svg"), testpath
    system bin/"svgo", "test.svg", "-o", "test.min.svg"
    assert_match /^<svg /, (testpath/"test.min.svg").read
  end
end
