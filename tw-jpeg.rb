class TwJpeg < Formula
  homepage "http://www.ijg.org"
  url "http://www.ijg.org/files/jpegsrc.v8d.tar.gz"
  sha1 "f080b2fffc7581f7d19b968092ba9ebc234556ff"

  keg_only "TeXworks build dependency."
  depends_on :macos => :mavericks

  def install
    ENV["MACOSX_DEPLOYMENT_TARGET"] = "10.9"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/djpeg", test_fixtures("test.jpg")
  end
end
