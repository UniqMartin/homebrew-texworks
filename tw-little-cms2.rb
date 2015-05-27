class TwLittleCms2 < Formula
  homepage "http://www.littlecms.com/"
  url "https://downloads.sourceforge.net/project/lcms/lcms/2.7/lcms2-2.7.tar.gz"
  sha256 "4524234ae7de185e6b6da5d31d6875085b2198bc63b1211f7dde6e2d197d6a53"

  keg_only "TeXworks build dependency."
  depends_on :macos => :mavericks

  depends_on "tw-jpeg"
  depends_on "tw-libtiff"

  def install
    ENV["MACOSX_DEPLOYMENT_TARGET"] = "10.9"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-jpeg",
                          "--with-tiff"
    system "make", "install"
  end

  test do
    system "#{bin}/jpgicc", test_fixtures("test.jpg"), "out.jpg"
    assert File.exist?("out.jpg")
  end
end
