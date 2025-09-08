# Reverse tunnel setup on a Bastion

The setup script here will setup a reverse tunnel to a given Bastion on a given port and will request that traffic to a given port on the Bastion is forwarded to it on port 22.  You can log into the server and run a ProxyCommand to connect to the port with the require identity files.  This results in you have a forwarded ssh connection via the Bastion to the remote device.

In AWS EC2 instances you must enable forwarding for a given group as follows.  Add the match group below to the sshd config file `/etc/ssh/sshd_config`

```bash
# Allow reverse tunneling for a specific group
Match Group tunnel-users
  GatewayPorts yes
```

Create a user on the EC2 server and add you local ssh key to authorized_keys
Add the remote device user ssh key to authorized_keys

Create a group and add the user to the group...

```bash
sudo groupadd <group_name>
sudo usermod -aG <group_name> <username>
```

Edit your local ssh config to add 2 new entries...

```bash

Host Bastion-User
    Hostname       18.171.220.101
    User           <your-username-to-login-to-bastion>
    IdentityFile   <id file that you use to loging to bastion e.g. ~/.ssh/id_rsa>

Host Bastion-<remote-hostname>
    Hostname       localhost
    Port           <port_number_here e.g. 8080>
    User           <remote user here e.g. pi>
    IdentityFile   <id file that you use to login to that remote e.g. ~/.ssh/id_rsa>
    ProxyJump      Bastion-User

```

Login to the remote (using the bastion) as follows...

`ssh Bastion-<remote-hostname>`
