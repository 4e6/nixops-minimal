{ vboxMemorySize ? 1024
, vboxVcpu ? 1
, vboxHeadless ? true }:

{
  network.description = "gce-mini";

  machine = { lib, ... }: {
    deployment.targetEnv = "virtualbox";
    deployment.virtualbox.memorySize = vboxMemorySize;
    deployment.virtualbox.vcpu = vboxVcpu;
    deployment.virtualbox.headless = vboxHeadless;
  };
}
