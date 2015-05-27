class TwPopplerQt4 < Formula
  homepage "http://poppler.freedesktop.org"
  url "http://poppler.freedesktop.org/poppler-0.29.0.tar.xz"
  sha1 "ba3330ab884e6a139ca63dd84d0c1c676f545b5e"

  keg_only "TeXworks build dependency."
  depends_on :macos => :mavericks

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
    ENV["MACOSX_DEPLOYMENT_TARGET"] = "10.9"
    ENV["PKG_CONFIG"] = Formula["tw-pkg-config"].bin/"pkg-config"

    # Required:
    #   * Backend used by TeXworks: --enable-splash-output
    #   * Poppler XPDF headers (?): --enable-xpdf-headers
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-xpdf-headers
      --enable-libopenjpeg
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
