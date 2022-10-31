class Zig < Formula
  desc "Programming language designed for robustness, optimality, and clarity"
  homepage "https://ziglang.org/"
  license "MIT"
  head "https://github.com/ziglang/zig.git", branch: "master"

  stable do
    url "https://ziglang.org/download/0.10.0/zig-0.10.0.tar.xz"
    sha256 "d8409f7aafc624770dcd050c8fa7e62578be8e6a10956bca3c86e8531c64c136"

    on_macos do
      # We need to make sure there is enough space in the MachO header when we rewrite install names.
      # https://github.com/ziglang/zig/issues/13388
      patch :DATA
    end
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "f07d304c8fb5ef31ac58004cd455d76064f739ba0b0992eb99c2b10160b060ad"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "3f3dacda44621fb6d7d0ba1ef241840059bd0876547ab12355238e53e325aef1"
    sha256 cellar: :any_skip_relocation, monterey:       "fb2a4b511bbde8f7e2ad4a00aa63442daced1e02e168b9c081eef1a8406319fb"
    sha256 cellar: :any_skip_relocation, big_sur:        "1c79f7eebaf0b0c7e97830aa43a630de27d1f1593dbed36f36f189dda269d451"
    sha256 cellar: :any_skip_relocation, catalina:       "647e8c20a77ba8c2711d3af2c8e7aac0bedeab99b2bc5ac73f8c4ea303c621a0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "95dbaeaabf3cc63df04c8fa46a19f74ef17e7f67cfeb7bfe0dd1e6be99cb399b"
  end

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on macos: :big_sur # https://github.com/ziglang/zig/issues/13313
  depends_on "z3"
  depends_on "zstd"
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  fails_with gcc: "5" # LLVM is built with GCC

  def install
    system "cmake", "-S", ".", "-B", "build", "-DZIG_STATIC_LLVM=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"hello.zig").write <<~EOS
      const std = @import("std");
      pub fn main() !void {
          const stdout = std.io.getStdOut().writer();
          try stdout.print("Hello, world!", .{});
      }
    EOS
    system "#{bin}/zig", "build-exe", "hello.zig"
    assert_equal "Hello, world!", shell_output("./hello")

    # error: 'TARGET_OS_IPHONE' is not defined, evaluates to 0
    # https://github.com/ziglang/zig/issues/10377
    ENV.delete "CPATH"
    (testpath/"hello.c").write <<~EOS
      #include <stdio.h>
      int main() {
        fprintf(stdout, "Hello, world!");
        return 0;
      }
    EOS
    system "#{bin}/zig", "cc", "hello.c", "-o", "hello"
    assert_equal "Hello, world!", shell_output("./hello")
  end
end

__END__
diff --git a/build.zig b/build.zig
index e5e80b4..1da6892 100644
--- a/build.zig
+++ b/build.zig
@@ -154,6 +154,7 @@ pub fn build(b: *Builder) !void {
 
     exe.stack_size = stack_size;
     exe.strip = strip;
+    exe.headerpad_max_install_names = true;
     exe.sanitize_thread = sanitize_thread;
     exe.build_id = b.option(bool, "build-id", "Include a build id note") orelse false;
     exe.install();
