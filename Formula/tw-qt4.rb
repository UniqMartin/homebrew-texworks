require File.expand_path("../../lib/tw-formula", __FILE__)

class TwQt4 < TwFormula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"
  revision 1

  url "https://download.qt.io/official_releases/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz"
  mirror "https://www.mirrorservice.org/sites/download.qt-project.org/official_releases/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz"
  sha256 "e2882295097e47fe089f8ac741a95fef47e0a73a3f3cdf21b56990638f626ea0"

  # Backport of Qt5 commit to fix the fatal build error on OS X El Capitan.
  # http://code.qt.io/cgit/qt/qtbase.git/commit/?id=b06304e164ba47351fa292662c1e6383c081b5ca
  if MacOS.version >= :el_capitan
    patch do
      url "https://raw.githubusercontent.com/Homebrew/patches/480b7142c4e2ae07de6028f672695eb927a34875/qt/el-capitan.patch"
      sha256 "c8a0fa819c8012a7cb70e902abb7133fc05235881ce230235d93719c47650c4e"
    end
  end

  depends_on "tw-pkg-config" => :build

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

  def caveats; <<-EOS.undent
    We agreed to the Qt opensource license for you.
    If this is unacceptable you should uninstall.
    EOS
  end

  test do
    system "#{bin}/qmake", "-project"
  end
end
