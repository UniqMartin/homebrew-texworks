require_relative "common/tw-formula"

class TwQt5 < TwFormula
  desc "Version 5 of the Qt framework"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/5.4/5.4.2/single/qt-everywhere-opensource-src-5.4.2.tar.xz"
  mirror "https://www.mirrorservice.org/sites/download.qt-project.org/official_releases/qt/5.4/5.4.2/single/qt-everywhere-opensource-src-5.4.2.tar.xz"
  sha256 "8c6d070613b721452f8cffdea6bddc82ce4f32f96703e3af02abb91a59f1ea25"

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
      -qt-libpng
      -qt-libjpeg
      -nomake examples
      -nomake tests
      -nomake tools
      -skip qtactiveqt
      -skip qtandroidextras
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

  test do
    system "#{bin}/qmake", "-project"
  end

  def caveats; <<-EOS.undent
    We agreed to the Qt opensource license for you.
    If this is unacceptable you should uninstall.
    EOS
  end
end
