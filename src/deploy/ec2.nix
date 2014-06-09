let
  region = "us-east-1";
  accessKeyId = "haskell";

  ec2 = { resources, ... }:
    { deployment.targetEnv = "ec2";
      deployment.ec2.accessKeyId  = accessKeyId;
      deployment.ec2.region       = region;
      deployment.ec2.instanceType = "m1.small";
      deployment.ec2.keyPair      = resources.ec2KeyPairs.haskell-keypair;
      deployment.ec2.securityGroups =
        [ "allow-ssh" "allow-http" "allow-https" ];
    };
in
{
  network.description = "Haskell.org (EC2)";

  planet      = ec2;
  mysql01     = ec2;
  wiki        = ec2;
  phabricator = ec2;
  darcs       = ec2;
  ghc         = ec2;
  www         = ec2;
  hackage     = ec2;
  monitor     = ec2;

  # Provision an EC2 key.
  resources.ec2KeyPairs.haskell-keypair =
    { inherit region accessKeyId; };
}
