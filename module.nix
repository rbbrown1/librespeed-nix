{ config, lib, pkgs, ... }:

let
  cfg = config.services.librespeed;
in
{
  options.services.librespeed = with lib; {
    enable = mkEnableOption "LibreSpeed speed test server (Rust backend)";

    package = mkOption {
      type = types.package;
      default = pkgs.librespeed-rs;
      defaultText = literalExpression "pkgs.librespeed-rs";
      description = "The librespeed-rs package to use.";
    };

    address = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Bind address for the server.";
    };

    port = mkOption {
      type = types.port;
      default = 8686;
      description = "Listen port for the server.";
    };

    workerThreads = mkOption {
      type = types.ints.positive;
      default = 1;
      description = "Number of worker threads (increase for better concurrency, but uses more memory).";
    };

    baseUrl = mkOption {
      type = types.str;
      default = "backend";
      description = "Base URL path for API routes (e.g., /backend/).";
    };

    ipinfoApiKey = mkOption {
      type = types.str;
      default = "";
      description = "Optional ipinfo.io API key for better ISP detection (falls back to offline DB).";
    };

    assetsPath = mkOption {
      type = types.path;
      default = "${cfg.package}/share/librespeed/assets";
      description = "Path to static frontend assets (set to empty string to disable frontend serving).";
    };

    # Add more options here if needed (e.g., stats_password from config.toml for enabling results page)
    # For full telemetry/results DB, you'd need to add SQLite options and config entries.
  };

  config = lib.mkIf cfg.enable {
    systemd.services.librespeed = {
      description = "LibreSpeed Speed Test Server (Rust)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/librespeed-rs -c \${STATE_DIRECTORY}/configs.toml";
        WorkingDirectory = "/var/lib/librespeed";
        StateDirectory = "librespeed";
        DynamicUser = true;
        Restart = "always";
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
      };

      preStart = ''
        cat > $STATE_DIRECTORY/configs.toml <<EOF
        stats_password=""
        bind_address="${cfg.address}"
        listen_port=${toString cfg.port}
        worker_threads=${toString cfg.workerThreads}
        base_url="${cfg.baseUrl}"
        ipinfo_api_key="${cfg.ipinfoApiKey}"
        assets_path="${cfg.assetsPath}"
        EOF
      '';
    };
  };
}
