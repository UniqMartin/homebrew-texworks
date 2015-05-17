require_relative "common/tw-formula"

class TwLibtiff < TwFormula
  homepage "http://www.remotesensing.org/libtiff/"
  url "ftp://ftp.remotesensing.org/pub/libtiff/tiff-4.0.3.tar.gz"
  mirror "http://download.osgeo.org/libtiff/tiff-4.0.3.tar.gz"
  sha256 "ea1aebe282319537fb2d4d7805f478dd4e0e05c33d0928baba76a7c963684872"

  depends_on "tw-jpeg"

  def install
    ENV.cxx11
    jpeg = Formula["tw-jpeg"].opt_prefix
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-x",
                          "--disable-lzma",
                          "--with-jpeg-include-dir=#{jpeg}/include",
                          "--with-jpeg-lib-dir=#{jpeg}/lib"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <tiffio.h>

      int main(int argc, char* argv[])
      {
        TIFF *out = TIFFOpen(argv[1], "w");
        TIFFSetField(out, TIFFTAG_IMAGEWIDTH, (uint32) 10);
        TIFFClose(out);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-ltiff", "-o", "test"
    system "./test", "test.tif"
    assert_match /ImageWidth.*10/, shell_output("#{bin}/tiffdump test.tif")
  end
end
