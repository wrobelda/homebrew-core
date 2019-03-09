require "language/node"

class KibanaAT56 < Formula
  desc "Analytics and search dashboard for Elasticsearch"
  homepage "https://www.elastic.co/products/kibana"
  url "https://github.com/elastic/kibana.git",
      :tag      => "v5.6.15",
      :revision => "e4f1e8f824c4cdc70bfa09a5ec734d7108366456"

  bottle do
    cellar :any_skip_relocation
    sha256 "e77a9456c5820ccf831e009f78b1525bf2404c7ec6eab48e5dc239d4af07326b" => :mojave
    sha256 "59e514aa5812dd4b716ccf73c34dbe059b5648c44dba99dc62246ddec3f03d79" => :high_sierra
    sha256 "a73908eab81376f25cb9b0d9b29505babba3236c4eb84fadce0e00defac9a325" => :sierra
  end

  keg_only :versioned_formula

  resource "node" do
    url "https://nodejs.org/dist/v6.16.0/node-v6.16.0.tar.xz"
    sha256 "0d0882a9da1ccc217518d3d1a60dd238da9f52bed0c7daac42b8dc3d83bd7546"
  end

  def install
    resource("node").stage do
      system "./configure", "--prefix=#{libexec}/node"
      system "make", "install"
    end

    # do not build packages for other platforms
    inreplace buildpath/"tasks/config/platforms.js", /('(linux-x64|windows-x64)',?(?!;))/, "// \\1"

    # trick the build into thinking we've already downloaded the Node.js binary
    mkdir_p buildpath/".node_binaries/#{resource("node").version}/darwin-x64"

    # set MACOSX_DEPLOYMENT_TARGET to compile native addons against libc++
    inreplace libexec/"node/include/node/common.gypi", "'MACOSX_DEPLOYMENT_TARGET': '10.7',",
                                                       "'MACOSX_DEPLOYMENT_TARGET': '#{MacOS.version}',"
    ENV["npm_config_nodedir"] = libexec/"node"

    # set npm env and fix cache edge case (https://github.com/Homebrew/brew/pull/37#issuecomment-208840366)
    ENV.prepend_path "PATH", prefix/"libexec/node/bin"
    system "npm", "install", "-ddd", "--build-from-source", "--#{Language::Node.npm_cache_config}"
    system "npm", "run", "build", "--", "--release", "--skip-os-packages", "--skip-archives"

    prefix.install Dir["build/kibana-#{version}-darwin-x86_64/{bin,config,node_modules,optimize,package.json,src,ui_framework,webpackShims}"]

    inreplace "#{bin}/kibana", %r{/node/bin/node}, "/libexec/node/bin/node"
    inreplace "#{bin}/kibana-plugin", %r{/node/bin/node}, "/libexec/node/bin/node"

    cd prefix do
      inreplace "config/kibana.yml", "/var/run/kibana.pid", var/"run/kibana.pid"
      (etc/"kibana").install Dir["config/*"]
      rm_rf "config"
    end
  end

  def post_install
    ln_s etc/"kibana", prefix/"config"
    (prefix/"data").mkdir
    (prefix/"plugins").mkdir
  end

  def caveats; <<~EOS
    Config: #{etc}/kibana/
    If you wish to preserve your plugins upon upgrade, make a copy of
    #{opt_prefix}/plugins before upgrading, and copy it into the
    new keg location after upgrading.
  EOS
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/kibana@5.6/bin/kibana"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>Program</key>
        <string>#{opt_bin}/kibana</string>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
  EOS
  end

  test do
    ENV["BABEL_CACHE_PATH"] = testpath/".babelcache.json"
    assert_match /#{version}/, shell_output("#{bin}/kibana -V")
  end
end
