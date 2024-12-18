class Joern < Formula
  desc "Open-source code analysis platform based on code property graphs"
  homepage "https://joern.io/"
  url "https://github.com/joernio/joern/archive/refs/tags/v4.0.170.tar.gz"
  sha256 "5dba2ee472f1fa47fc82020fb9e5bb452d268d28352646f57da11432f5a54cfb"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    throttle 10
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d0b0996de9b3d6e467e458fafc9c4198da89e904cc8e209f188d247009f7b313"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "ef7e85413519322fce84938da2547e2efe468839d51f46acd563a69779a5845e"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "e33c06b8102c587d02cf70e0891bd62e3a14086bb5468f609539c9ad337dfa67"
    sha256 cellar: :any_skip_relocation, sonoma:        "650732a842076b21f93e3b65d201f6b4bf466664aced05cab70c0d1bde153818"
    sha256 cellar: :any_skip_relocation, ventura:       "98f87a80c8b11c81b9f924612479c24300cac96a459565305a1d055c0f5c67f1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "85ac1b44662e25ddd72fb9e459427dbefef29ecce725b125d80f8a674af39c4b"
  end

  depends_on "sbt" => :build
  depends_on "astgen"
  depends_on "coreutils"
  depends_on "openjdk"
  depends_on "php"

  uses_from_macos "zlib"

  def install
    system "sbt", "stage"

    cd "joern-cli/target/universal/stage" do
      rm(Dir["**/*.bat"])
      libexec.install Pathname.pwd.children
    end

    # Remove incompatible pre-built binaries
    os = OS.mac? ? "macos" : OS.kernel_name.downcase
    astgen_suffix = Hardware::CPU.intel? ? [os] : ["#{os}-#{Hardware::CPU.arch}", "#{os}-arm"]
    libexec.glob("frontends/{csharp,go,js}src2cpg/bin/astgen/{dotnet,go,}astgen-*").each do |f|
      f.unlink unless f.basename.to_s.end_with?(*astgen_suffix)
    end

    libexec.children.select { |f| f.file? && f.executable? }.each do |f|
      (bin/f.basename).write_env_script f, Language::Java.overridable_java_home_env
    end
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <iostream>
      void print_number(int x) {
        std::cout << x << std::endl;
      }

      int main(void) {
        print_number(42);
        return 0;
      }
    CPP

    assert_match "Parsing code", shell_output("#{bin}/joern-parse test.cpp")
    assert_predicate testpath/"cpg.bin", :exist?
  end
end
