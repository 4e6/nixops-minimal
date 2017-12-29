{ gceProject ? builtins.getEnv "GCE_PROJECT"
, gceServiceAccount ? builtins.getEnv "GCE_SERVICE_ACCOUNT"
, accessKeyPath ? builtins.getEnv "ACCESS_KEY_PATH"
, gceInstanceType ? "f1-micro"
, gceNetwork ? "mini-net"
, gceRegion ? "us-central1-f" }:

{
  network.description = "gce-mini";

  resources.gceNetworks."${gceNetwork}" = {
    name = gceNetwork;
    addressRange = "192.168.4.0/24";
  };

  machine = { lib, ... }: {
    deployment.targetEnv = "gce";
    deployment.gce = {
      region = gceRegion;
      network = gceNetwork;
    };

    # Fix NixOS/nixpkgs#24273
    # Disable service by overriding the `script` attribute
    systemd.services.fetch-ssh-keys = { ... }: {
      options = {
        script = lib.mkOption {
          apply = _: "true";
        };
      };
    };

    # Fix NixOS/nixops#823
    # This is a terrible hack
    systemd.services.backup-ssh-keys = {
      description = "Backup ssh keys before they overwritten by the google-instance-setup.service";

      requiredBy = [ "google-instance-setup.service" ];
      before = [ "google-instance-setup.service" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];

      script = ''
        cp -v /etc/ssh/ssh_host_ed25519_key /root
        cp -v /etc/ssh/ssh_host_ed25519_key.pub /root
      '';
    };

    systemd.services.restore-ssh-keys = {
      description = "Restore ssh keys after the google-instance-setup.service finishes";

      wantedBy = [ "sshd.service" ];
      before = [ "sshd.service" ];
      after = [ "google-instance-setup.service" ];
      requires = [ "google-instance-setup.service" ];

      script = ''
        cp -vf /root/ssh_host_ed25519_key /etc/ssh/
        cp -vf /root/ssh_host_ed25519_key.pub /etc/ssh/
      '';
    };

  };
}
