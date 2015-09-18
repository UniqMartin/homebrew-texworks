require_relative "common/tw-formula"

class TwOpenjpeg < TwFormula
  desc "Library for JPEG-2000 image manipulation"
  homepage "http://www.openjpeg.org"
  url "https://mirrors.kernel.org/debian/pool/main/o/openjpeg/openjpeg_1.5.2.orig.tar.gz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/o/openjpeg/openjpeg_1.5.2.orig.tar.gz"
  sha256 "aef498a293b4e75fa1ca8e367c3f32ed08e028d3557b069bf8584d0c1346026d"
  revision 1

  depends_on "cmake" => :build

  def install
    # Disabling all binaries also removes all external dependencies.
    system "cmake", ".", *std_cmake_args,
                         "-DBUILD_CODEC:bool=off",
                         "-DBUILD_MJ2:bool=off",
                         "-DBUILD_JPWL:bool=off",
                         "-DBUILD_JPIP:bool=off"
    system "make", "install"

    # https://github.com/uclouvain/openjpeg/issues/562
    (lib/"pkgconfig").install_symlink lib/"pkgconfig/libopenjpeg1.pc" => "libopenjpeg.pc"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <openjpeg.h>

      int main () {
        opj_image_cmptparm_t cmptparm;
        const OPJ_COLOR_SPACE color_space = CLRSPC_GRAY;

        opj_image_t *image;
        image = opj_image_create(1, &cmptparm, color_space);

        opj_image_destroy(image);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}/openjpeg-1.5", "-L#{lib}", "-lopenjpeg",
           testpath/"test.c", "-o", "test"
    system "./test"
  end
end
