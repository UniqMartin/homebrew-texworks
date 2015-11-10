require File.expand_path("../../lib/tw-formula", __FILE__)

class TwPopplerData < TwFormula
  desc "PDF rendering library (based on the xpdf-3.0 code base)"
  homepage "http://poppler.freedesktop.org"
  url "http://poppler.freedesktop.org/poppler-data-0.4.7.tar.gz"
  sha256 "e752b0d88a7aba54574152143e7bf76436a7ef51977c55d6bd9a48dccde3a7de"

  def install
    system "make", "install", "prefix=#{prefix}"
  end
end
