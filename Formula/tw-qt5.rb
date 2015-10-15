require File.expand_path("../../lib/tw-formula", __FILE__)

# Patches for Qt5 must be at the very least submitted to Qt's Gerrit codereview
# rather than their bug-report Jira. The latter is rarely reviewed by Qt.
class TwQt5 < TwFormula
  desc "Version 5 of the Qt framework"
  homepage "https://www.qt.io/"
  revision 1

  url "https://download.qt.io/official_releases/qt/5.5/5.5.1/single/qt-everywhere-opensource-src-5.5.1.tar.xz"
  mirror "https://www.mirrorservice.org/sites/download.qt-project.org/official_releases/qt/5.5/5.5.1/single/qt-everywhere-opensource-src-5.5.1.tar.xz"
  sha256 "6f028e63d4992be2b4a5526f2ef3bfa2fe28c5c757554b11d9e8d86189652518"

  # Build error: Fix library detection for QtWebEngine with Xcode 7.
  # https://codereview.qt-project.org/#/c/127759/
  patch do
    url "https://raw.githubusercontent.com/UniqMartin/patches/557a8bd4/qt5/webengine-xcode7.patch"
    sha256 "7bd46f8729fa2c20bc486ddc5586213ccf2fb9d307b3d4e82daa78a2553f59bc"
  end

  # Fix for qmake producing broken pkg-config files, affecting Poppler et al.
  # https://codereview.qt-project.org/#/c/126584/
  # Should land in the 5.5.2 and/or 5.6 release.
  patch do
    url "https://raw.githubusercontent.com/UniqMartin/patches/557a8bd4/qt5/qtbug-47162.patch"
    sha256 "e410087f4209b692e6cee6eb7161d72f9b23d110d0a6214eb980ca169cef7102"
  end

  # Build issue: Fix install names with `-no-rpath` to be absolute paths.
  # https://codereview.qt-project.org/#/c/138349
  patch do
    url "https://raw.githubusercontent.com/UniqMartin/patches/77d138fa/qt5/osx-no-rpath.patch"
    sha256 "92c9cfe701f9152f4b16219a04a523338d4b77bb0725a8adccc3fc72c9fb576f"
  end

  depends_on :xcode => :build

  def install
    # We really only care about 10.9+. Prevent Qt from being too stubborn.
    inreplace "qtbase/mkspecs/macx-clang/qmake.conf",
              "QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.7",
              "QMAKE_MACOSX_DEPLOYMENT_TARGET = #{TwFormula::TW_DEPLOYMENT_TARGET}"

    # The '-make tools' part brings in a lot of GUI tools we do not care about.
    # However, it also disables useful command-line tools like 'macdeployqt' we
    # would like to retain. Patching 'qttools/src/src.pro' solves this for us.
    inreplace "qttools/src/src.pro", /\n    macdeployqt \\$/, ""

    # Disable all modules not used by TeXworks.
    args = %W[
      -prefix #{prefix}
      -bindir #{libexec}/bin
      -release
      -confirm-license
      -opensource
      -c++11
      -no-sql-sqlite
      -no-qml-debug
      -platform macx-clang
      -system-zlib
      -securetransport
      -qt-libpng
      -qt-libjpeg
      -no-rpath
      -no-openssl
      -nomake examples
      -nomake tests
      -nomake tools
      -skip qt3d
      -skip qtactiveqt
      -skip qtandroidextras
      -skip qtcanvas3d
      -skip qtconnectivity
      -skip qtdeclarative
      -skip qtenginio
      -skip qtgraphicaleffects
      -skip qtlocation
      -skip qtmultimedia
      -skip qtquick1
      -skip qtquickcontrols
      -skip qtsensors
      -skip qtserialport
      -skip qtsvg
      -skip qtwayland
      -skip qtwebchannel
      -skip qtwebengine
      -skip qtwebkit
      -skip qtwebkit-examples
      -skip qtwebsockets
      -skip qtwinextras
      -skip qtx11extras
      -skip qtxmlpatterns
      -no-dbus
      -no-opengl
      -arch x86_64
    ]

    system "./configure", *args
    system "make"
    ENV.j1
    system "make", "install"

    # `*.prl` files created by `qmake` contain references to the temporary build
    # directory, which is not very helpful. Remove those references.
    Pathname.glob("#{lib}/**/*.prl") do |path|
      inreplace path, /^QMAKE_PRL_BUILD_DIR = .*\n/, ""
    end

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # configure saved PKG_CONFIG_LIBDIR set up by superenv; remove it
    # see: https://github.com/Homebrew/homebrew/issues/27184
    inreplace prefix/"mkspecs/qconfig.pri", /\n\n# pkgconfig/, ""
    inreplace prefix/"mkspecs/qconfig.pri", /\nPKG_CONFIG_.*=.*$/, ""

    # We install binaries into `libexec/bin` as we don't want to have `*.app`
    # bundles in `bin` and we cannot simply move them somewhere else after being
    # installed as some paths are hard-coded. Symlink relevant stuff into `bin`.
    (libexec/"bin").children.each do |path|
      next if path.directory? || !path.executable?
      next if path.basename.to_s == "syncqt.pl" # Skip tools internal to Qt.
      bin.install_symlink path
    end

    # Link `*.app` bundles into `libexec` to expose them to `brew linkapps`.
    Pathname.glob("#{libexec}/bin/*.app") do |app|
      libexec.install_symlink app => "#{app.basename(".app")}-#{name}.app"
    end
  end

  def caveats; <<-EOS.undent
    We agreed to the Qt opensource license for you.
    If this is unacceptable you should uninstall.
    EOS
  end

  test do
    (testpath/"hello.pro").write <<-EOS.undent
      QT       += core
      QT       -= gui
      TARGET = hello
      CONFIG   += console
      CONFIG   -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    EOS

    (testpath/"main.cpp").write <<-EOS.undent
      #include <QCoreApplication>
      #include <QDebug>

      int main(int argc, char *argv[])
      {
        QCoreApplication a(argc, argv);
        qDebug() << "Hello World!";
        return 0;
      }
    EOS

    system bin/"qmake", testpath/"hello.pro"
    system "make"
    assert File.exist?("hello")
    assert File.exist?("main.o")
    system "./hello"
  end
end
