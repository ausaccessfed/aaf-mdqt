module MDQT
  class CLI
    require 'mdqt/cli/base'

    Options =
      Struct.new(
        :service,
        :hash,
        :cache,
        :refresh,
        :verify_with,
        :validate,
        :all,
        :explain,
        :tls_risky,
        :save_to,
        :list,
        :verbose,
        :memcache,
        :no_output,
        :cli,
      ) do
        def initialize(**args)
          options = {
            service: :not_required,
            hash: nil,
            cache: nil,
            refresh: nil,
            verify_with: nil,
            validate: nil,
            all: nil,
            explain: nil,
            tls_risky: nil,
            save_to: nil,
            list: nil,
            verbose: nil,
            memcache: nil,
            no_output: nil,
            cli: true,
            **MDQT::CLI::Defaults.cli_defaults
          }
          super(**options, **args)
        end
      end
  end
end

