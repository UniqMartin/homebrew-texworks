require_relative "common/tw-formula"

class TwPopplerData < TwFormula
  desc "PDF rendering library (based on the xpdf-3.0 code base)"
  homepage "http://poppler.freedesktop.org"
  url "http://poppler.freedesktop.org/poppler-data-0.4.7.tar.gz"
  sha1 "556a5bebd0eb743e0d91819ba11fd79947d8c674"

  def install
    system "make", "install", "prefix=#{prefix}"
  end
end
