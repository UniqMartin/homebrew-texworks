require File.expand_path("../../lib/tw-formula", __FILE__)

class TwFreetype < TwFormula
  desc "Software library to render fonts"
  homepage "http://www.freetype.org"
  url "https://downloads.sf.net/project/freetype/freetype2/2.6/freetype-2.6.tar.bz2"
  mirror "http://download.savannah.gnu.org/releases/freetype/freetype-2.6.tar.bz2"
  sha256 "8469fb8124764f85029cc8247c31e132a2c5e51084ddce2a44ea32ee4ae8347e"
  revision 1

  depends_on "tw-libpng"

  # Don't define a TYPEOF macro in ftconfig.h
  # https://savannah.nongnu.org/bugs/index.php?45376
  # http://git.savannah.gnu.org/cgit/freetype/freetype2.git/commit/?id=5931268eecaeda3e05580bdc8885348fecc43fa8
  patch do
    url "https://gist.githubusercontent.com/anonymous/b47d77c41a6801879fd2/raw/fc21c3516b465095da7ed13f98bea491a7d18bbd/patch"
    sha256 "5b21575d0384c9e502b51b0ba4be0ff453a34bcf9deba52b6baa38c3ffcde063"
  end

  def install
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
