class Auditbeat < Formula
  desc "Lightweight Shipper for Audit Data"
  homepage "https://www.elastic.co/products/beats/auditbeat"
  url "https://github.com/elastic/beats.git",
      :tag      => "v6.6.1",
      :revision => "928f5e3f35fe28c1bd73513ff1cc89406eb212a6"
  head "https://github.com/elastic/beats.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "510071d1030d7aeb2ef1b147d94cd2c5dc16bee13d4db6434286a8b6ed4eaab3" => :mojave
    sha256 "b035f34cbf9b97ed1061be71e7ba4cc15614964db82219c1a385199307fe2724" => :high_sierra
    sha256 "299d6df634d7147e816051760c42ded348f0a74962ec0b3a4af010aff2d22d34" => :sierra
  end

  depends_on "go" => :build
  depends_on "python@2" => :build

  resource "virtualenv" do
    url "https://files.pythonhosted.org/packages/8b/f4/360aa656ddb0f4168aeaa1057d8784b95d1ce12f34332c1cf52420b6db4e/virtualenv-16.3.0.tar.gz"
    sha256 "729f0bcab430e4ef137646805b5b1d8efbb43fe53d4a0f33328624a84a5121f7"
  end

  # Patch required to build against go 1.11 (Can be removed with v7.0.0)
  # partially backport of https://github.com/elastic/beats/commit/8d8eaf34a6cb5f3b4565bf40ca0dc9681efea93c
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/881f5d1d/auditbeat/go1.11.diff"
    sha256 "1747ea917ccd4c627fdc412d41b340ec96ce705f529b6e9d91e9bdf482eb792d"
  end

  def install
    # remove non open source files
    rm_rf "x-pack"

    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/elastic/beats").install buildpath.children

    ENV.prepend_create_path "PYTHONPATH", buildpath/"vendor/lib/python2.7/site-packages"

    resource("virtualenv").stage do
      system "python", *Language::Python.setup_install_args(buildpath/"vendor")
    end

    ENV.prepend_path "PATH", buildpath/"vendor/bin" # for virtualenv
    ENV.prepend_path "PATH", buildpath/"bin" # for mage (build tool)

    cd "src/github.com/elastic/beats/auditbeat" do
      # don't build docs because it would fail creating the combined OSS/x-pack
      # docs and we aren't installing them anyway
      inreplace "magefile.go", "mage.GenerateModuleIncludeListGo, Docs)",
                               "mage.GenerateModuleIncludeListGo)"

      system "make", "mage"
      # prevent downloading binary wheels during python setup
      system "make", "PIP_INSTALL_COMMANDS=--no-binary :all", "python-env"
      system "mage", "-v", "build"
      system "mage", "-v", "update"

      (etc/"auditbeat").install Dir["auditbeat.*", "fields.yml"]
      (libexec/"bin").install "auditbeat"
      prefix.install "build/kibana"
    end

    prefix.install_metafiles buildpath/"src/github.com/elastic/beats"

    (bin/"auditbeat").write <<~EOS
      #!/bin/sh
      exec #{libexec}/bin/auditbeat \
        --path.config #{etc}/auditbeat \
        --path.data #{var}/lib/auditbeat \
        --path.home #{prefix} \
        --path.logs #{var}/log/auditbeat \
        "$@"
    EOS
  end

  def post_install
    (var/"lib/auditbeat").mkpath
    (var/"log/auditbeat").mkpath
  end

  plist_options :manual => "auditbeat"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>Program</key>
        <string>#{opt_bin}/auditbeat</string>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
  EOS
  end

  test do
    (testpath/"files").mkpath
    (testpath/"config/auditbeat.yml").write <<~EOS
      auditbeat.modules:
      - module: file_integrity
        paths:
          - #{testpath}/files
      output.file:
        path: "#{testpath}/auditbeat"
        filename: auditbeat
    EOS
    pid = fork do
      exec "#{bin}/auditbeat", "-path.config", testpath/"config", "-path.data", testpath/"data"
    end
    sleep 5

    begin
      touch testpath/"files/touch"
      sleep 30
      s = IO.readlines(testpath/"auditbeat/auditbeat").last(1)[0]
      assert_match "\"action\":\[\"created\"\]", s
      realdirpath = File.realdirpath(testpath)
      assert_match "\"path\":\"#{realdirpath}/files/touch\"", s
    ensure
      Process.kill "SIGINT", pid
      Process.wait pid
    end
  end
end
