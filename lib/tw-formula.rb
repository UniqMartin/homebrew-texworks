class TwFormula < Formula
  # Our deployment target. All formulae should use this constant, to simplify
  # changes in the future.
  TW_DEPLOYMENT_TARGET = "10.9"

  # Keeps track if we already augmented :install from formula.
  @tw_install_patched = false

  # Injects additional dependencies and stuff.
  def self.inherited(subclass)
    subclass.__send__(:keg_only, "TeXworks build dependency.")
    subclass.__send__(:depends_on, :macos => :mavericks)
  end

  # Augments formula method 'install' to include a few more things.
  def self.method_added(method)
    # Let base 'Formula' react to method additions, e.g. for 'test do' blocks.
    super(method)

    # Check what is being added and patch (but only once).
    return unless method == :install
    return if @tw_install_patched
    @tw_install_patched = true

    # Replace method 'install' from formula with our extended version.
    class_exec do
      alias_method :tw_install_original, :install
      alias_method :install, :tw_install
    end
  end

  # Logs messages generated by out extended 'install' method.
  def tw_log(message)
    puts "#{Tty.green}[TwFormula]#{Tty.reset} #{message}"
  end

  # Performs preparations and then calls the original 'install' method.
  def tw_install
    tw_install_prepare
    tw_install_original
  end

  # Performs preparations prior to invocation of original 'install' method.
  def tw_install_prepare
    tw_log "Preparing install for TeXworks dependency."

    # Put the deployment target in the environment. Unfortunately, not all build
    # systems respect this.
    tw_log "  Setting OS X deployment target."
    ENV["MACOSX_DEPLOYMENT_TARGET"] = TwFormula::TW_DEPLOYMENT_TARGET

    # If formula depends on 'tw-pkg-config', force it into environment.
    if stable.deps.any? { |dep| dep.name == "tw-pkg-config" }
      tw_log "  Setting PKG_CONFIG in ENV."
      ENV["PKG_CONFIG"] = Formula["tw-pkg-config"].bin / "pkg-config"
    end
  end
end
