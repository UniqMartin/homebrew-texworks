require_relative "common/tw-formula"

# Patches for Qt5 must be at the very least submitted to Qt's Gerrit codereview
# rather than their bug-report Jira. The latter is rarely reviewed by Qt.
class TwQt5 < TwFormula
  desc "Version 5 of the Qt framework"
  homepage "https://www.qt.io/"

  # 5.5.0 has a compile-breaking pkg-config error when projects use that to find libs.
  # https://bugreports.qt.io/browse/QTBUG-47162
  # This is known to impact Wireshark & Poppler optional Qt5 usage in the core.
  url "https://download.qt.io/official_releases/qt/5.5/5.5.0/single/qt-everywhere-opensource-src-5.5.0.tar.xz"
  mirror "https://www.mirrorservice.org/sites/download.qt-project.org/official_releases/qt/5.5/5.5.0/single/qt-everywhere-opensource-src-5.5.0.tar.xz"
  sha256 "7ea2a16ecb8088e67db86b0835b887d5316121aeef9565d5d19be3d539a2c2af"

  # Apple's 3.6.0svn based clang doesn't support -Winconsistent-missing-override
  # https://bugreports.qt.io/browse/QTBUG-46833
  # This is fixed in 5.5 branch and below patch should be removed
  # when this formula is updated to 5.5.1
  patch :DATA

  # Upstream commit to fix the fatal build error on OS X El Capitan.
  # https://codereview.qt-project.org/#/c/121545/
  # Should land in the 5.5.1 release.
  if MacOS.version >= :el_capitan
    patch do
      url "https://raw.githubusercontent.com/DomT4/scripts/2107043e8/Homebrew_Resources/Qt5/qt5_el_capitan.diff"
      sha256 "bd8fd054247ec730f60778e210d58cba613265e5df04ec93f4110421fb03b14a"
    end
  end

  depends_on "tw-pkg-config" => :build
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

__END__
diff --git a/qtbase/src/corelib/global/qcompilerdetection.h b/qtbase/src/corelib/global/qcompilerdetection.h
index 7ff1b67..060af29 100644
--- a/qtbase/src/corelib/global/qcompilerdetection.h
+++ b/qtbase/src/corelib/global/qcompilerdetection.h
@@ -155,7 +155,7 @@
 /* Clang also masquerades as GCC */
 #    if defined(__apple_build_version__)
 #      /* http://en.wikipedia.org/wiki/Xcode#Toolchain_Versions */
-#      if __apple_build_version__ >= 6020049
+#      if __apple_build_version__ >= 7000053
 #        define Q_CC_CLANG 306
 #      elif __apple_build_version__ >= 6000051
 #        define Q_CC_CLANG 305
