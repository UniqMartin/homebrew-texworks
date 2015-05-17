class TwFormula < Formula
  # Our deployment target. All formulae should use this constant, to simplify
  # changes in the future.
  TW_DEPLOYMENT_TARGET = "10.9"

  # Keep track if we already augmented :install from formula.
  @tw_install_patched = FALSE

  # Inject additional dependencies and stuff.
  def self.inherited subclass
    subclass.__send__ :keg_only, "TeXworks build dependency."
    subclass.__send__ :depends_on, :macos => :mavericks
  end

  # Augment formula method :install to include a few more things.
  def self.method_added method
    # Check what is being added and patch (but only once).
    if method != :install || @tw_install_patched
      return
    end
    @tw_install_patched = TRUE

    # Augment :install from formula with our extended version.
    alias_method :tw_install, :install
    module_eval do
      def install
        puts "[TwFormula] Preparing install for TeXworks dependency."

        # Put the deployment target in the environment. Unfortunately, not all
        # build systems respect this.
        puts "[TwFormula]   Setting OS X deployment target."
        ENV["MACOSX_DEPLOYMENT_TARGET"] = TwFormula::TW_DEPLOYMENT_TARGET

        # If formula depends on 'tw-pkg-config', force it into environment.
        if stable.deps.map(&:name).include?("tw-pkg-config")
          puts "[TwFormula]   Setting PKG_CONFIG in ENV."
          ENV["PKG_CONFIG"] = Formula["tw-pkg-config"].bin/"pkg-config"
        end

        # Call original implementation from formula.
        tw_install
      end
    end
  end
end
