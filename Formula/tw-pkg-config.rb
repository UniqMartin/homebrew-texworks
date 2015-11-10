require File.expand_path("../../lib/tw-formula", __FILE__)

class TwPkgConfig < TwFormula
  desc "Manage compile and link flags for libraries"
  homepage "https://wiki.freedesktop.org/www/Software/pkg-config/"
  url "http://pkgconfig.freedesktop.org/releases/pkg-config-0.29.tar.gz"
  mirror "https://fossies.org/linux/misc/pkg-config-0.29.tar.gz"
  sha256 "c8507705d2a10c67f385d66ca2aae31e81770cc0734b4191eb8c489e864a006b"

  def install
    pc_path = %W[
      /usr/lib/pkgconfig
      #{HOMEBREW_LIBRARY}/ENV/pkgconfig/#{MacOS.version}
    ].uniq.join(File::PATH_SEPARATOR)

    ENV.append "LDFLAGS", "-framework Foundation -framework Cocoa"
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--disable-host-tool",
                          "--with-internal-glib",
                          "--with-pc-path=#{pc_path}"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    system "#{bin}/pkg-config", "--libs", "openssl"
  end
end
