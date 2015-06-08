require_relative "common/tw-formula"

class TwQt4 < TwFormula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/4.8/4.8.6/qt-everywhere-opensource-src-4.8.6.tar.gz"
  mirror "http://qtmirror.ics.com/pub/qtproject/official_releases/qt/4.8/4.8.6/qt-everywhere-opensource-src-4.8.6.tar.gz"
  sha256 "8b14dd91b52862e09b8e6a963507b74bc2580787d171feda197badfa7034032c"

  depends_on "tw-pkg-config" => :build

  # This patch should be able to be removed with the next stable Qt4 release.
  patch do
    url "https://raw.githubusercontent.com/DomT4/scripts/440e3cafde5bf6ec6f50cd28fa5bf89c280f1b53/Homebrew_Resources/Qt/qt4patch.diff"
    sha256 "b0e597a95b40efe36b093230d0fe3c0461aaa24eb6ff01e084e37e1f61f88114"
  end

  def install
    # We really only care about 10.9+. Prevent Qt from being too stubborn.
    inreplace "mkspecs/unsupported/macx-clang-libc++/qmake.conf",
              "QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.7",
              "QMAKE_MACOSX_DEPLOYMENT_TARGET = #{TwFormula::TW_DEPLOYMENT_TARGET}"

    # The '-make tools' part brings in a lot of GUI tools we do not care about.
    # Unfortunately, we cannot just disable it, as it also provides some useful
    # command-line tools and the vital 'QtUiTools' module. Solve this conflict
    # by patching 'tools/tools.pro'.
    inreplace "tools/tools.pro",
              /^!contains\(QT_CONFIG, no-gui\)/,
              "SUBDIRS += designer/src/uitools\ncontains(QT_CONFIG, gui-tools)"
    inreplace "tools/linguist/linguist.pro",
              /:!contains\(QT_CONFIG, no-gui\):/,
              ":contains(QT_CONFIG, gui-tools):"

    # Disable all modules not used by TeXworks.
    args = %W[
      -prefix #{prefix}
      -release
      -confirm-license
      -opensource
      -fast
      -no-sql-sqlite
      -no-qt3support
      -no-xmlpatterns
      -no-multimedia
      -no-audio-backend
      -no-phonon
      -no-phonon-backend
      -no-svg
      -no-webkit
      -no-javascript-jit
      -no-declarative
      -no-declarative-debug
      -platform unsupported/macx-clang-libc++
      -system-zlib
      -qt-libtiff
      -qt-libpng
      -no-libmng
      -qt-libjpeg
      -no-openssl
      -nomake demos
      -nomake docs
      -nomake examples
      -no-dbus
      -no-opengl
      -arch x86_64
    ]

    system "./configure", *args
    system "make"
    ENV.j1
    system "make", "install"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    Pathname.glob("#{bin}/*.app") { |app| mv app, prefix }
  end

  test do
    system "#{bin}/qmake", "-project"
  end

  def caveats; <<-EOS.undent
    We agreed to the Qt opensource license for you.
    If this is unacceptable you should uninstall.
    EOS
  end
end
