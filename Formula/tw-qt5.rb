require File.expand_path("../../lib/tw-formula", __FILE__)

# Patches for Qt5 must be at the very least submitted to Qt's Gerrit codereview
# rather than their bug-report Jira. The latter is rarely reviewed by Qt.
class TwQt5 < TwFormula
  desc "Version 5 of the Qt framework"
  homepage "https://www.qt.io/"

  url "https://download.qt.io/official_releases/qt/5.5/5.5.1/single/qt-everywhere-opensource-src-5.5.1.tar.xz"
  mirror "https://www.mirrorservice.org/sites/download.qt-project.org/official_releases/qt/5.5/5.5.1/single/qt-everywhere-opensource-src-5.5.1.tar.xz"
  sha256 "6f028e63d4992be2b4a5526f2ef3bfa2fe28c5c757554b11d9e8d86189652518"

  # Build error: Fix library paths with Xcode 7 for QtWebEngine.
  # https://codereview.qt-project.org/#/c/122729/
  patch do
    url "https://raw.githubusercontent.com/Homebrew/patches/2fcc1f8ec1df1c90785f4fa6632cebac68772fa9/qt5/el-capitan-2.diff"
    sha256 "b8f04efd047eeed7cfd15b029ece20b5fe3c0960b74f7a5cb98bd36475463227"
  end

  # Fix for qmake producing broken pkg-config files, affecting Poppler et al.
  # https://codereview.qt-project.org/#/c/126584/
  # Should land in the 5.5.2 and/or 5.6 release.
  patch do
    url "https://gist.githubusercontent.com/UniqMartin/a54542d666be1983dc83/raw/f235dfb418c3d0d086c3baae520d538bae0b1c70/qtbug-47162.patch"
    sha256 "e31df5d0c5f8a9e738823299cb6ed5f5951314a28d4a4f9f021f423963038432"
  end

  depends_on :xcode => :build

  def install
    # We really only care about 10.9+. Prevent Qt from being too stubborn.
    inreplace "qtbase/mkspecs/macx-clang/qmake.conf",
              "QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.7",
              "QMAKE_MACOSX_DEPLOYMENT_TARGET = #{TwFormula::TW_DEPLOYMENT_TARGET}"

    # Disable all modules not used by TeXworks.
    args = %W[
      -prefix #{prefix}
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

    Pathname.glob("#{bin}/*.app") { |app| mv app, prefix }
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
