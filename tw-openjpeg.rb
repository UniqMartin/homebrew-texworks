require_relative "common/tw-formula"

class TwOpenjpeg < TwFormula
  homepage "http://www.openjpeg.org/"
  url "https://openjpeg.googlecode.com/files/openjpeg-1.5.1.tar.gz"
  sha1 "1b0b74d1af4c297fd82806a9325bb544caf9bb8b"
  revision 1

  depends_on "tw-pkg-config" => :build
  depends_on "tw-little-cms2" # recommended
  depends_on "tw-libtiff"     # recommended
  depends_on "tw-libpng"      # recommended

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-doc",
                          "--enable-png",
                          "--enable-tiff",
                          "--disable-lcms1",
                          "--enable-lcms2"
    system "make", "install"
  end
end
