class TwFreetype < Formula
  homepage "http://www.freetype.org"
  url "https://downloads.sf.net/project/freetype/freetype2/2.5.5/freetype-2.5.5.tar.bz2"
  sha1 "7b7460ef51a8fdb17baae53c6658fc1ad000a1c2"

  keg_only "TeXworks build dependency."
  depends_on :macos => :mavericks

  depends_on "tw-libpng"

  def install
    ENV["MACOSX_DEPLOYMENT_TARGET"] = "10.9"

    inreplace "include/config/ftoption.h",
        "/* #define FT_CONFIG_OPTION_SUBPIXEL_RENDERING */",
        "#define FT_CONFIG_OPTION_SUBPIXEL_RENDERING"

    system "./configure", "--prefix=#{prefix}", "--without-harfbuzz"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/freetype-config", "--cflags", "--libs", "--ftversion",
      "--exec-prefix", "--prefix"
  end
end
