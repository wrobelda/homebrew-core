class Anyenv < Formula
  desc "All in one for **env"
  homepage "https://anyenv.github.io/"
  url "https://github.com/anyenv/anyenv/archive/v1.0.1.tar.gz"
  sha256 "5d42ac8748db41b8ec0cb3ad986bb10084e55df0153366403ea458e7a958a1a7"

  bottle do
    cellar :any_skip_relocation
    sha256 "e151eaa92c93a0c8e33a1f285cf3fc3abf98b7eab601df1cafa1b57d98d543a3" => :mojave
    sha256 "288be8d02cec3886f56eea01f494fd0b3ffdf28ed6d323566a1b533b2cce9e43" => :high_sierra
    sha256 "288be8d02cec3886f56eea01f494fd0b3ffdf28ed6d323566a1b533b2cce9e43" => :sierra
  end

  def install
    prefix.install %w[bin completions libexec]
  end

  test do
    Dir.mktmpdir do |dir|
      profile = "#{dir}/.profile"
      File.open(profile, "w") do |f|
        content = <<~EOS
          export ANYENV_ROOT=#{dir}/anyenv
          export ANYENV_DEFINITION_ROOT=#{dir}/anyenv-install
          eval "$(anyenv init -)"
        EOS
        f.write(content)
      end

      cmds = <<~EOS
        anyenv install --force-init
        anyenv install --list
        anyenv install rbenv
        rbenv install --list
      EOS
      cmds.split("\n").each do |cmd|
        shell_output("source #{profile} && #{cmd}")
      end
    end
  end
end
