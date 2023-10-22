{ pkgs, config, ...}:
{
  # ref: https://beb.ninja/post/installing-podman/
  config.home.packages = with pkgs; [
    podman
    runc
    skopeo
    conmon
    slirp4netns
  ];

  # These are needed for podman to run
  # sudo echo "potatoq:100001:65534" > /etc/subuid
  # sudo echo "potatoq:100001:65534" > /etc/subgid
  #subUidRanges = [
  #  { count = 65534; startUid = 100001; }
  #];
  #subGidRanges = [
  #  { count = 65534; startGid = 100001; }
  #];

  config.home.file."registries.conf" = {
    target = ".config/containers/registries.conf";
    text = ''
      [registries.search]
      registries = [
        'docker.io', 'registry.gitlab.com', 
        'registry.fedoraproject.org', 
        'quay.io', 'registry.access.redhat.com', 
        'registry.centos.org'
      ]
    '';
  };

  config.home.file."policy.json" = {
    target = ".config/containers/policy.json";
    text = ''
      {
        "default": [
          {
            "type": "insecureAcceptAnything"
          }
        ],
        "transports": {
          "docker-daemon": {
            "": [{"type":"insecureAcceptAnything"}]
          }
        }
      }
    '';
  };
}