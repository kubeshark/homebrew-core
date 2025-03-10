class Repomix < Formula
  desc "Pack repository contents into a single AI-friendly file"
  homepage "https://github.com/yamadashy/repomix"
  url "https://registry.npmjs.org/repomix/-/repomix-0.2.31.tgz"
  sha256 "2ac4b17eb3f9699b491f84dc54a84945d61574d20331233665ef3b29b7dbcc9c"
  license "MIT"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "0ce051ee4f07d669214e1f2cf55d2c96ae82395ec967eed7e0e65f0b72835ed8"
    sha256 cellar: :any,                 arm64_sonoma:  "0ce051ee4f07d669214e1f2cf55d2c96ae82395ec967eed7e0e65f0b72835ed8"
    sha256 cellar: :any,                 arm64_ventura: "0ce051ee4f07d669214e1f2cf55d2c96ae82395ec967eed7e0e65f0b72835ed8"
    sha256 cellar: :any,                 sonoma:        "568693155e63d4ed4e852b547a1aa4a0d62dfa7dd80fd7202ddef9b82851aba2"
    sha256 cellar: :any,                 ventura:       "568693155e63d4ed4e852b547a1aa4a0d62dfa7dd80fd7202ddef9b82851aba2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "31bffc2d39de573b8a9fee11f97d8678eb04c8266f2e79be8d5daaef1304863f"
  end

  depends_on "node"

  on_linux do
    depends_on "xsel"
  end

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]

    clipboardy_fallbacks_dir = libexec/"lib/node_modules/#{name}/node_modules/clipboardy/fallbacks"
    rm_r(clipboardy_fallbacks_dir) # remove pre-built binaries
    if OS.linux?
      linux_dir = clipboardy_fallbacks_dir/"linux"
      linux_dir.mkpath
      # Replace the vendored pre-built xsel with one we build ourselves
      ln_sf (Formula["xsel"].opt_bin/"xsel").relative_path_from(linux_dir), linux_dir
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/repomix --version")

    (testpath/"test_repo").mkdir
    (testpath/"test_repo/test_file.txt").write("Test content")

    output = shell_output("#{bin}/repomix #{testpath}/test_repo")
    assert_match "Packing completed successfully!", output
    assert_match "This file is a merged representation of the entire codebase", (testpath/"repomix-output.txt").read
  end
end
