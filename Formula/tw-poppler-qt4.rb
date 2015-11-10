require File.expand_path("../../lib/tw-formula", __FILE__)

class TwPopplerQt4 < TwFormula
  desc "PDF rendering library (based on the xpdf-3.0 code base)"
  homepage "http://poppler.freedesktop.org"
  url "http://poppler.freedesktop.org/poppler-0.37.0.tar.xz"
  sha256 "b89f9c5eae3bbb1046b0f767714afd75eca102a0406a3a30856778d42a685bee"

  depends_on "tw-pkg-config" => :build
  depends_on "tw-poppler-data" # (outsourced)
  depends_on "tw-fontconfig"   # required
  depends_on "tw-freetype"     # required
  depends_on "tw-jpeg"         # recommended
  depends_on "tw-libpng"       # required
  depends_on "tw-libtiff"      # optional
  depends_on "tw-openjpeg"     # recommended
  depends_on "tw-qt4"          # required
  depends_on "tw-little-cms2"  # optional

  def install
    ENV["LIBOPENJPEG_CFLAGS"] = "-I#{Formula["tw-openjpeg"].opt_include}/openjpeg-1.5"

    # Required:
    #   * Backend used by TeXworks: --enable-splash-output
    #   * Poppler XPDF headers (?): --enable-xpdf-headers
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-xpdf-headers
      --enable-libopenjpeg=auto
      --enable-libtiff
      --enable-libjpeg
      --enable-libpng
      --enable-splash-output
      --disable-cairo-output
      --disable-poppler-glib
      --enable-introspection=no
      --enable-gtk-doc=no
      --enable-gtk-doc-html=no
      --enable-gtk-doc-pdf=no
      --enable-poppler-qt4
      --disable-poppler-qt5
      --disable-poppler-cpp
      --disable-gtk-test
      --disable-utils
      --enable-cms=lcms2
    ]

    system "./configure", *args
    system "make", "install"
  end
end
