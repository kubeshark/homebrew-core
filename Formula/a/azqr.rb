class Azqr < Formula
  desc "Azure Quick Review"
  homepage "https://azure.github.io/azqr/"
  url "https://github.com/Azure/azqr.git",
      tag:      "v.2.4.0",
      revision: "4fd83411f9b285a8f5b5038c0396726eb65cef82"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "34076ab350175e77f968dfbc64949f8aedf5fddede4693ee86a745d6b6fed5c9"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "34076ab350175e77f968dfbc64949f8aedf5fddede4693ee86a745d6b6fed5c9"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "34076ab350175e77f968dfbc64949f8aedf5fddede4693ee86a745d6b6fed5c9"
    sha256 cellar: :any_skip_relocation, sonoma:        "6f4b0dea949b8438ab96a6a3b7bc1dc66a4f8f9f5498e9729fbecdea36135599"
    sha256 cellar: :any_skip_relocation, ventura:       "6f4b0dea949b8438ab96a6a3b7bc1dc66a4f8f9f5498e9729fbecdea36135599"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ae83ec9b68aa2240c2951e7a9fd34e818dcebd28fbf701a35eb0c85d30515485"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/Azure/azqr/cmd/azqr.version=#{version}"), "./cmd"

    generate_completions_from_executable(bin/"azqr", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/azqr -v")
    output = shell_output("#{bin}/azqr scan --filters notexists.yaml 2>&1", 1)
    assert_includes output, "failed reading data from file"
    output = shell_output("#{bin}/azqr scan 2>&1", 1)
    assert_includes output, "Failed to list subscriptions"
  end
end
