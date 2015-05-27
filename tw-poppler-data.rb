class TwPopplerData < Formula
  homepage "http://poppler.freedesktop.org"
  url "http://poppler.freedesktop.org/poppler-data-0.4.7.tar.gz"
  sha1 "556a5bebd0eb743e0d91819ba11fd79947d8c674"

  keg_only "TeXworks build dependency."
  depends_on :macos => :mavericks

  def install
    ENV["MACOSX_DEPLOYMENT_TARGET"] = "10.9"

    system "make", "install", "prefix=#{prefix}"
  end
end
