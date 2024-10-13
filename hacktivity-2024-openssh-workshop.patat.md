---
title: 'Exploring OpenSSH: Hands-On Workshop for Beginners'
author: 'William Robinet (Conostix S.A.)'
patat:
    wrap: true
    margins:
        left: auto
        right: auto
        top: auto
    syntaxDefinitions:
        - 'schematics.xml'
    theme:
        syntaxHighlighting:
            keyword: [bold, rgb#FF0000]
            import: [bold, rgb#00FF00]
            builtIn: [bold, rgb#0000FF]
#    transition:
#        type: slideLeft
#        duration: 0.2
geometry: "left=1cm,right=1cm,top=1cm,bottom=1cm"
output: pdf_document
...

**Hacktivity 2024 - Budapest**

**Exploring OpenSSH: Hands-On Workshop for Beginners**

William Robinet (Conostix S.A.) - 2024-10-14

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Before we begin 1/2

## Workshop resources

Matrix Room (cfr paper QR Code):

**https://matrix.to/#/#Hacktivity\_2024-OpenSSH\_Workshop:matrix.org**

Used to exchange links and commands.

Workshop repository (cfr paper QR Code):

**https://github.com/wllm-rbnt/hacktivity-2024-openssh-workshop/**

```bash
git clone https://github.com/wllm-rbnt/hacktivity-2024-openssh-workshop.git
cd hacktivity-2024-openssh-workshop
```

Shorter URLs:

- Matrix Room -> **https://tinyurl.com/52bftbc7**
- Repository -> **https://tinyurl.com/3z5n9ppb**
- Slides:
    * Markdown (source version) -> **https://tinyurl.com/4muxcxrz**
    * HTML (rendered version) -> **https://tinyurl.com/4jpsm4nr**
    * PDF (rendered version) -> **https://tinyurl.com/2jmkfsfy**

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Before we begin 2/2

Slides are written in Markdown

Get the *PDF*/*HTML* versions or use *patat* to render the presentation in your terminal

Go to release page **https://github.com/jaspervdj/patat/releases** and download version 0.12.0.1

or

```bash
wget https://github.com/jaspervdj/patat/releases/download/v0.12.0.1/patat-v0.12.0.1-linux-x86_64.tar.gz
tar xzf patat-v0.12.0.1-linux-x86_64.tar.gz patat-v0.12.0.1-linux-x86_64/patat
patat-v0.12.0.1-linux-x86_64/patat hacktivity-2024-openssh-workshop.patat.md
```

The Markdown version can be converted to PDF & HTML by using the provided
*md2pdf.sh* script (*pandoc* & *chromium* must be installed first)

---

<!--config:
margins:
    left: 10
    right: 10
-->

# About me

* Introduced to Open Source & Free Software around the end of the 90's
* CompSci studies, work in IT at Conostix S.A. - AS197692
* ssldump improvements (build system, bug fixes, JSON output, IPv6 & ja3(s), ...)
* asn1template: painless ASN.1 editing
* 🎸 🏃 🚵 🔭 ⏚ ...

* GitHub: **https://github.com/wllm-rbnt/**
* Mastodon: **https://infosec.exchange/@wr**

---

<!--config:
wrap: false
margins:
    left: 10
    right: 10
-->

# Local Machine Setup

## Docker Installation

Reference documentation:
    **https://docs.docker.com/engine/install/**

This will provide `docker compose` v2 command (with a space).

On Debian 12 (bookworm), the following command will provide `docker-compose` v1 command (with a dash).
```bash
sudo apt install docker.io docker-compose
```

On Ubuntu 24.10, the `docker compose` v2 command can be installed directly:
```bash
sudo apt install docker.io docker-compose-v2
```

On Rocky Linux 9, install `docker-ce` with `docker compose` v2 commmand:
```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl --now enable docker
```

## Various other tools

We will use `netcat` (`netcat-traditional` on Debian/Ubuntu), `curl`, `wireshark` (or `tcpdump`).

---

<!--config:
wrap: false
margins:
    left: 10
    right: 10
-->

# Labs Network Layout

```sshschema
 ┌───────────────────┐              ┌───────────────────────────────────────────┐
 │ Local Network     │              │ Lab network (containers)                  │
 │ ┌───────────────┐ │              │ ┌─────────────┐          ┌──────────────┐ │
 │ │     local     │ │<------------>│ │   gateway   │          │   internal   │ │
 │ └───────────────┘ │ The_Internet │ └─────────────┘          └──────────────┘ │
 │  IP: 172.18.0.1   │              │  Pub 172.18.0.2                           │
 │                   │              │  Priv 172.19.0.2 <-LAN-> Priv 172.19.0.3  │
 └───────────────────┘              └───────────────────────────────────────────┘
```

(IP addresses may differ from your Docker setup)

Your *local* machine can reach `gateway` server over 'The Internet'

* *local* machine is your personal laptop or VM. It is located "somewhere on the Internet"
    It is able to reach `gateway` on TCP port 22 (on 172.18.0.2)

* **Lab network** is a remote private LAN (172.19.0.0/16 in this case)

* On this remote LAN, `gateway` is privately known as 172.19.0.2.

* `gateway` is connected to another machine named **internal** (172.19.0.3)

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Usernames and Passwords 

2 users exist on each container: *root* and *user*.

Passwords are the same as usernames. *user* has **sudo** access on each machine (no password required).

# Shell commands

Shell commands are prefixed by a prompt designating the machine on which the command shall be run:

```sshschema
(local)$ <local command>
(gateway)$ <remote command on gateway machine>
(internal)$ <remote command on internal machine>
```

# IP addresses

* IP addresses are configured statically when you execute `start_containers.sh`

* 3 IP addresses will appear during this workshop
    + <gateway_pub\>
    + <gateway_priv\>
    + <internal_priv\>

--- 

<!--config:
wrap: false
margins:
    left: 10
    right: 10
-->

# Labs Containers

* 2 containers will be used during this workshop, one for *gateway* and a second for *internal*

* Build and start containers with:
```sshschema
(local)$ cd docker
(local)$ ./build_containers.sh
(local)$ ./start_containers.sh
```

 * Print setup information:
```sshschema
(local)$ ./get_info.sh
```

 * Stop containers with:
```sshschema
(local)$ ./stop_containers.sh
```
   
* Cleanup the whole Docker setup:
    **WARNING this will remove all containers, images and networks from your local Docker setup**
    
```sshschema
(local)$ ./docker_wipe.sh
(local)$ sudo systemctl restart docker
```
    
---

<!--config:
margins:
    left: 10
    right: 10
-->

# Illustration: Telnet is not secure

* A *telnet* server is listening on *gateway*, TCP port 23

* Start a traffic capture on TCP port 23 in another terminal:

```sshschema
(local)$ sudo apt install wireshark
(local)$ sudo wireshark
```

* Start a capture on your main network interface (*eth0*) or *any*
* Then, in another shell, run the *telnet* client on your local machine:
```sshschema
(local)$ sudo apt install telnet
(local)$ telnet 172.18.0.2
```

* Login, *user* Password, *user*

* Finally, right-click on the first TCP packet that belongs to this connection (port 23), then *Follow* -> *TCP Stream*

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Two main issues:

- Cleartext message exchange: vulnerable to traffic sniffing
    tcpdump/wireshark on traffic path (firewall, router)

- Insecure authentication: vulnerable to Man-In-The-Middle attack
    Ettercap (another machine on same LAN), proxy software on an intermediate router/firewall

Same goes for FTP, HTTP, SMTP, ...

---

<!--config:
margins:
    left: 10
    right: 10
-->

# SSH History  & Implementations

SSH stands for **S**ecure **SH**ell

## Protocol Versions

- [SSH-1.0](https://en.wikipedia.org/wiki/Secure_Shell#Version_1) 1995, by Tatu Ylönen, researcher at Helsinki University of Technology
- [SSH-2.0](https://datatracker.ietf.org/doc/html/rfc4254) 2006, IETF Standardization RFC 4251-4256
- [SSH-1.99](https://datatracker.ietf.org/doc/html/rfc4253#section-5.1) Retro-compatibility pseudo-version, Old client/New Server
- [SSH3](https://github.com/francoismichel/ssh3) (?) Experimental implementation using HTTP/3 (QUIC)

## Implementations

- OpenSSH on Unices, Client & Server for GNU/Linux, \*BSD, MacOS, ...
- OpenSSH on MS Windows
- Terminal & File transfer clients for MS Windows: PuTTY, MobaXterm, WinSCP, FileZilla, ...
- Dropbear, Lightweight implementation, for embedded-type Linux (or other Unices) systems
- On mobile: ConnectBot for Android, Termius for Apple iOS
- Network Appliances, OpenSSH or custom implementation

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Focus on OpenSSH Tool suite (on GNU/Linux)

- Focus on the OpenSSH tool suite, a project started in 1999
- Clients & Server software
- This is the reference opensource version for many OSes
- It is based on modern cryptography algorithms and protocols
- It is widely available out-of-the-box
- It contains a wide range of tools (remote shell, file transfer, key management, ...)
- Automation friendly (Ansible, or custom scripts)
- Main tools
    * *ssh* - Remote terminal access
    * *scp* - File transfer
    * *sftp* - FTP-like file transfer
- Helpers
    * *ssh-keygen* - Public/Private keypair generation
    * *ssh-copy-id* - Key deployment script
    * *ssh-agent* - Key management daemon (equivalent to PuTTY's pageant.exe)
    * *ssh-add* - Key/Agent management tool

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Documentation

Online manual pages

* Listing of **C**ommand **LI**ne man pages:

    `$ man -k ssh`
    
* Listing client's configuration options:

    `$ man ssh_config`

* Listing server's configuration options (the *openssh-server* package must be installed):

    `$ man sshd_config`

* CLI help, in your terminal, just type
    * `ssh` for the client
    * `/usr/sbin/sshd --help` for the server
    * `ssh-keygen --help` for the key management tool
    * ...

---

<!--config:
margins:
    left: 10
    right: 10
-->

# First Login (1/2) - Commands, tcpdump & fingerprints

Syntax is: `ssh <username>@<host>`, where *<host>* can be a hostname or an IP address

Username and password are the same as the one from the telnet example:
- Username: *user* / Password: *user*

- Start a traffic capture on TCP port 22 in another terminal, traffic is **encrypted**:

```sshschema
(local)$ sudo tcpdump -n -i any -XXX tcp and port 22
```

- Retrieve the server keys fingerprints through a secure channel:

    **https://github.com/wllm-rbnt/hacktivity-2024-openssh-workshop/blob/main/fingerprints.txt**
 
---

<!--config:
margins:
    left: 10
    right: 10
-->

# First Login (2/2) - Connection & host authentication

Type the following in a local terminal on your machine:

```sshschema
(local)$ ssh user@<gateway_pub>
or
(local)$ ssh -o VisualHostKey=true user@<gateway_pub>
The authenticity of host '172.18.0.2 (172.18.0.2)' can't be established.
ED25519 key fingerprint is SHA256:HFofTLfh2W/1IR3+g0sXGAcRs4ZnVsWwGKmbOzeMefk.
+--[ED25519 256]--+
|          . +B=*o|
|         o ooBX.o|
|        o oo=Oo=.|
|       + o..= o.*|
|      . S .o o o=|
|          o . o..|
|           = o   |
|          = *    |
|           + oE  |
+----[SHA256]-----+
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

- Type *yes* to accept and go on with user authentication, or *no* to refuse and disconnect immediately
- or type the *fingerprint* you received from the secure channel
  If the fingerprint you entered matches the one that is printed, the system will proceed with user authentication
   
---

<!--config:
margins:
    left: 10
    right: 10
-->

# Known hosts fingerprint databases

Remote Host Authentication is performed only on first connection

`~/.ssh/known_hosts` is then populated with host reference and corresponding key fingerprint

`/etc/ssh/ssh_known_hosts` can be used as a system-wide database of know hosts

Hosts references can be stored as clear text (IP or hostname) or the corresponding hash (see *HashKnownHosts* option)

# Host keys location on OpenSSH server

```sshschema
(gateway)$ ls -l /etc/ssh/ssh_host*pub
-rw------- 1 root root  513 May 23 12:39 /etc/ssh/ssh_host_ecdsa_key
-rw-r--r-- 1 root root  179 May 23 12:39 /etc/ssh/ssh_host_ecdsa_key.pub
-rw------- 1 root root  411 May 23 12:39 /etc/ssh/ssh_host_ed25519_key
-rw-r--r-- 1 root root   99 May 23 12:39 /etc/ssh/ssh_host_ed25519_key.pub
-rw------- 1 root root 2602 May 23 12:39 /etc/ssh/ssh_host_rsa_key
-rw-r--r-- 1 root root  571 May 23 12:39 /etc/ssh/ssh_host_rsa_key.pub
```

# Computing fingerprints of host keys

```sshschema
(gateway)$ for i in $(ls -1 /etc/ssh/ssh_host*pub); do ssh-keygen -lf $i; done
256 SHA256:gbF30TEqv4ucpI3VFIEjq0dnrji5woxacnPe+N9mFX8 root@460a6cac3a3c (ECDSA)
256 SHA256:/hUAOroJsQzhM4f9qSZxcBLqEYqmoPi03pVX2fQUxrg root@460a6cac3a3c (ED25519)
3072 SHA256:D0gvg+2kFzvrLjqi0OEZ23tnQN3H/+oB3cqm0VZHWiQ root@460a6cac3a3c (RSA)
```

Note: use `ssh-keygen -lvf <public_key_file>` to generate the visual ASCII art representation of a key 

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Configuration (1/2)

## Configuration files

Client:

- Per-user client configuration: `~/.ssh/config`
- System-wide client configuration: `/etc/ssh/ssh_config`
- System-wide local configuration: `/etc/ssh/ssh_config.d/*`

Server:

- Server configuration: `/etc/ssh/sshd_config`
- Server local configuration: `/etc/ssh/sshd_config.d/*`

## Configuration options

- Client configuration options: `$ man ssh_config`
- Server configuration options: `$ man sshd_config`

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Configuration (2/2) - Per host client configuration

Client configuration options can be specified per host

Example:

Type following in your local `~/.ssh/config`:

```sshschema
Host gateway
    Hostname <gateway_pub>
    User user
```

Tips: Printing the "would be applied" configuration

The `-G` parameter cause `ssh` to print the configuration that would be applied
for a given connection (without actually connecting)

```sshschema
(local)$ ssh -G gateway
```

The following command should output your username:

```sshschema
(local)$ ssh -G gateway | grep user
user user
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Tips

## Increase verbosity

Launch ssh commands with -v parameter in order to increase verbosity, and help with debugging

Example:

```sshschema
(local)$ ssh -v user@<gateway_pub>
OpenSSH_8.4p1 Debian-5+deb11u2, OpenSSL 1.1.1w  11 Sep 2023
debug1: Reading configuration data /home/user/.ssh/config
debug1: Reading configuration data /etc/ssh/ssh_config
[...]
```

## Escape character

The escape character can be used to pass out-of-band commands to ssh client

- By default `~`, must be at beginning of a new line
- Commands:
    + Quit current session `~.`
    + List Forwarded connections `~#`
    + Decrease the verbosity (LogLevel) `~V`
    + Increase the verbosity (LogLevel) `~v`
- Repeat `~` char in order to type it ( `~~` ) 

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Public Key Authentication (1/2)

## Main Authentication Methods
- *Password* authentication
- *Public/Private key* authentication
    + Used for password-less authentication (passphrase may be required to unlock private key)

## Lab
- Generate a new key pair on your local system (with or without a passphrase):

```sshschema
(local)$ ssh-keygen -f ~/.ssh/my-ssh-key
```
- Install your public key on the remote server:

```sshschema
(local)$ ssh-copy-id -i ~/.ssh/my-ssh-key.pub user@<gateway_pub>
```

**Note**: `ssh-copy-id` copies the public key from `~/.ssh/my-ssh-key.pub` to the remote machine in `~/.ssh/authorized_keys`

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Public Key Authentication (2/2)


- Login again with your new key pair:

```sshschema
(local)$ ssh -i ~/.ssh/my-ssh-key user@<gateway_pub>
```

- Reference your key pair in your personal local configuration file (`~/.ssh/config`):

```sshschema
Host gateway
    Hostname <gateway_pub>
    User user
    IdentityFile ~/.ssh/my-ssh-key
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Authentication Agent (1/2)

The Authentication Agent can hold access to private keys, thus eliminating the
need to enter passphrase at each use

Start the agent:

```sshschema
(local)$ ssh-agent | tee ssh-agent-env.sh
SSH_AUTH_SOCK=/tmp/ssh-KwTcl7ZieUKD/agent.1193973; export SSH_AUTH_SOCK;
SSH_AGENT_PID=1193974; export SSH_AGENT_PID;
echo Agent pid 1193974;
(local)$ source ssh-agent-env.sh
Agent pid 1193974
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Authentication Agent (2/2)

Load private key into the agent:

```sshschema
(local)$ ssh-add ~/.ssh/my-ssh-key
Enter passphrase for /home/user/.ssh/my-ssh-key: ********
Identity added: my-ssh-key (user@local)
```

Connect to remote machine:

```sshschema
(local)$ ssh user@<gateway_pub>
```

Going further, [keychain](https://www.funtoo.org/Funtoo:Keychain) can be used to manage ssh-agent & keys across logins sessions

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Remote Command Execution (1/2)

Simple command execution:

```sshschema
(local)$ ssh user@<gateway_pub> hostname
```

With redirection to local file:

```sshschema
(local)$ ssh user@<gateway_pub> hostname > hostname.txt
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Remote Command Execution (2/2)

With redirection to remote file:

```sshschema
(local)$ ssh user@<gateway_pub> "hostname > hostname.txt"
```

With pipes:

```sshschema
(local)$ echo blabla | ssh user@<gateway_pub> "cat - | tr 'a-z' 'A-Z'"
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Jumphost (1/2)

A Jump Host is a machine used as a relay to reach another, otherwise possibly
unreachable, machine. This unreachable machine is named internal-machine

```sshschema
 ┌────────────────────┐      ┌───────────────────────────────────────────────┐
 │ Internet           │      │ Internal network                              │
 │                    │      │                                               │
 │ ┌───────────────┐  │      │ ┌─────────────┐          ┌──────────────────┐ │
 │ │     local     ├──┼──────┤►│   gateway   ├─────────►│     internal     │ │
 │ └───────────────┘  │      │ └─────────────┘          └──────────────────┘ │
 │                    │      │  used as jumphost         unreachable to      │ 
 │                    │      │                           the outside world   │
 └────────────────────┘      └───────────────────────────────────────────────┘
```

*Lab objective*:
Connect to *internal* from your local machine via SSH with a single command

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Jumphost (2/2)

Lab setup:

- First, copy your public key to the remote server (gateway):

```sshschema
(local)$ scp .ssh/my-ssh-key.pub user@<gateway_pub>:
```

- Login to the remote server then copy your public key to the destination machine:

```sshschema
(local)$ ssh user@<gateway_pub>
(gateway)$ ssh-copy-id -f -i my-ssh-key.pub <internal_priv>
```

- Connect to the remote machine with a single command:

```sshschema
(local)$ ssh -J user@<gateway_pub> user@<internal_priv>
```

**Note**: *internal* host key fingerprints available at **https://github.com/wllm-rbnt/hacktivity-2024-openssh-workshop/blob/main/fingerprints.txt**

---

<!--config:
margins:
    left: 10
    right: 10
-->

# SOCKS proxy (1/2)

A *SOCKS server* proxies TCP connections to arbitrary IP addresses and ports

With SOCKS 5, DNS queries can be performed by the proxy on behalf of the client

```sshschema
 ┌───────────────────────┐            ┌─────────────────────────────────────────────┐
 │ Local network         │            │ Internal network                            │
 │                       │            │                                             │
 │   ┌───────────────┐   │   Step 1   │ ┌─────────────┐  Step 3  ┌────────────────┐ │
 │   │     local     ├───┼────────────┤►│   gateway   ├─────────►│    internal    │ │
 │   └─┬───────────▲─┘   │    SSH     │ └─────────────┘  HTTP    └────────────────┘ │
 │     │   SOCKS   │     │            │  The SOCKS proxy         The internal HTTP  │
 │     └───────────┘     │            │                          server             │
 │         Step 2        │            │                                             │
 └───────────────────────┘            └─────────────────────────────────────────────┘
```

*Lab objective*: Reach the internal HTTP server at http://secret-intranet (running on internal)
through a SOCKS proxy running on *gateway*

---

<!--config:
margins:
    left: 10
    right: 10
-->

# SOCKS proxy (2/2)

* Start a local SOCKS Proxy by establishing an SSH connection to *gateway* with parameter `-D`:

```sshschema
(local)$ ssh -D 1234 user@<gateway_pub>
```

* Check, locally, for listening TCP port with

```sshschema
(local)$ ss -tpln | grep :1234
```

* Configure your local browser to use local TCP port 1234 as a SOCKS proxy
* Configure your local browser to send DNS queries though the SOCKS proxy (tick the option in configuration)
* Point your browser to http://secret-intranet or Try it with curl:

```sshschema
(local)$ http_proxy=socks5h://127.0.0.1:1234 curl http://secret-intranet
This is the secret Intranet on internal machine listening on 127.0.0.1 port 80.
```

* Bonus: look at your local traffic with *tcpdump*, you shouldn't see any DNS exchanges

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Reverse SOCKS proxy (1/2)

A reverse SOCKS proxy setup allows a remote machine to use your local machine as a SOCKS proxy

```sshschema
 ┌───────────────────────┐          ┌───────────────────────────────────────────┐
 │   Internet            │          │ Internal network                          │
 │                       │          │                                           │
 │   ┌───────────────┐   │  Step 1  │ ┌─────────────┐          ┌──────────────┐ │
 │   │     local     ├───┼──────────┤►│   gateway   ├─────────►│   internal   │ │
 │   └┬──────────────┘   │   SSH    │ └─▲─────────┬─┘          └──────────────┘ │
 │    │ Step 3           │          │   │         │                             │
 │    ▼ HTTP             │          │   │ Step 2  │                             │
 │  http://icanhazip.com │          │   └─────────┘                             │
 │                       │          │     SOCKS                                 │
 └───────────────────────┘          └───────────────────────────────────────────┘
```

*Lab objective*: Reach the external HTTP server at **http://icanhazip.com** from *gateway*
through a SOCKS proxy running on your local machine

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Reverse SOCKS proxy (2/2)

Setup:

* Start a remote SOCKS Proxy by establishing an SSH connection to *gateway* with parameter -R:
```sshschema
(local)$ ssh -R 1234 user@<gateway_pub> 
```

* Check, on *gateway*, for listening TCP port with
```sshschema
(gateway)$ ss -tpln | grep :1234
```

* Point your curl on *gateway* to **http://icanhazip.com** though the SOCKS proxy listening on 127.0.0.1:1234:

```sshschema
(gateway)$ http_proxy=socks5h://127.0.0.1:1234 curl http://icanhazip.com
<Conference public IP address>
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# LocalForward (1/2)

A *LocalForward* creates a locally listening TCP socket that is connected over
SSH to a TCP port reachable in the network scope of a remote machine

*Lab objective:* Create and connect local listening TCP socket on port 8888 to TCP port 80 on
  127.0.0.1 in the context of *gateway*

Setup:

* Configure the forwarding while connecting to *gateway* through SSH with -L parameter:
```sshschema
(local)$ ssh -L 8888:127.0.0.1:80 user@<gateway_pub>
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# LocalForward (2/2)

`-L` parameter syntax:

`<local_port>:<remote_IP>:<remote_port>`

can be extended to

`<local_IP>:<local_port>:<remote_IP>:<remote_port>`

* SSH is now listening on TCP port 8888 on your local machine, check with:
```sshschema
(local)$ ss -tpln
```

* Point your browser to **http://127.0.0.1:8888**
  You should see something like:

    Hello world !
    This is gateway listening on 127.0.0.1 port 80.


---

<!--config:
margins:
    left: 10
    right: 10
-->

# RemoteForward (1/2)

A *RemoteForward* creates a listening TCP socket on a remote machine that is
connected over SSH to a TCP port reachable in the network scope of the local machine

*Lab objective*: Create a TCP socket on *gateway* on port 8123 and connect it to a locally listening netcat on TCP port 1234

Setup:

* Start a listening service on localhost on your local machine on TCP port 1234:
```sshschema
(local)$ nc -l -p 1234 -s 127.0.0.1 # if you use netcat-traditional
or
(local)$ nc -l 127.0.0.1 1234 # if you use netcat-openbsd
```

* Check that it's listening with `ss` (`netstat` replacement on GNU/Linux):
```sshschema
(local)$ ss -tpln | grep 1234
```

* Configure the forwarding on TCP port 8123 while connecting to *gateway* with `-R` parameter:

```sshschema
(local)$ ssh -R 8123:127.0.0.1:1234 user@<gateway_pub>
```

* `ssh` is now listening on TCP port 8123 on *gateway*

---

<!--config:
margins:
    left: 10
    right: 10
-->

# RemoteForward (2/2)


`-R` parameter syntax:

`<remote_port>:<local_IP>:<local_port>`

can be extended to

`<remote_IP>:<remote_port>:<local_IP>:<local_port>`


* Check its listening status on gateway:
```sshschema
(gateway)$ ss -tpln | grep 8123
```

* Connect to the forwarded service on remote machine on port 8123 with netcat:
```sshschema
(gateway)$ nc 127.0.0.1 8123
```

* Both netcat instances, local & remote, should be able to communicate with each other

**Note**: reverse proxy SOCKS is a special use case of `-R`

---

<!--config:
margins:
    left: 10
    right: 10
-->

# X11 Forwarding

*Lab objective:* Start a graphical application on *gateway*, and get the visual feedback locally

*Setup*:

* Connect to *gateway* with `-X` parameter: 
```sshschema
(local)$ ssh -X user@<gateway_pub>
```
* Then, start a graphical application on the remote machine:

```sshschema
(gateway)$ xmessage "This is a test !" &!
```

* Check processes on *gateway* and *local* machine:
```sshschema
(gateway|local)$ ps auxf
```

**Notes:**

* On a Linux local client, the XOrg graphical server is used
* On a Windows machine use:
    + VcXsrv: **https://sourceforge.net/~/vcxsrv/**
    + or XMing: **https://sourceforge.net/~/xming/**

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Connection to Legacy Systems (1/4)

## Host key algorithm mismatch

"Unable to negotiate with 10.11.12.13 port 22: no matching host key type found. Their offer: ssh-rsa"

```sshschema
(local)$ ssh -o HostKeyAlgorithms=ssh-rsa <user>@<machine>
```

* Listing known host key algorithms:
```sshschema
(local)$ ssh -Q key
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Connection to Legacy Systems (2/4)

## Wrong key exchange algorithm

"Unable to negotiate with 10.11.12.13 port 22: no matching key exchange method found. Their offer: diffie-hellman-group-exchange-sha1"

```sshschema
(local)$ ssh -o KexAlgorithms=diffie-hellman-group1-sha1 <user>@<machine>
```

* Listing known key exchange algorithms:
```sshschema
(local)$ ssh -Q kex
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Connection to Legacy Systems (3/4)

## Wrong cipher

"Unable to negotiate with 10.11.12.13 port 22: no matching cipher found. Their offer: aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc"

```sshschema
(local)$ ssh -o Ciphers=aes256-cbc <user>@<machine>
```

* Listing known ciphers:
```sshschema
(local)$ ssh -Q cipher
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# Connection to Legacy Systems (4/4)

## Wrong public key signature algorithm

"debug1: send_pubkey_test: no mutual signature algorithm" (with ssh -v)

```sshschema
(local)$ ssh -o PubkeyAcceptedAlgorithms=ssh-rsa <user>@<machine>
```

* Listing known public key sig algorithms:
```sshschema
(local)$ ssh -Q key-sig
```
or
```sshschema
(local)$ ssh -Q PubkeyAcceptedAlgorithms
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# SSH Tarpit

- The legitimate SSH server is running on port 22 on *gateway*
- `endlessh`, a simple honeypot, is running on port 2222 on *gateway* for demonstration purpose
- Try to connect to port 2222 with 

```sshschema
(local)$ ssh user@<gateway_pub> -p 2222
```

- Check both ports with `netcat`:

```sshschema
(local)$ nc -nv <gateway_pub> 22
(UNKNOWN) [<gateway_pub>] 22 (ssh) open
SSH-2.0-OpenSSH_9.2p1 Debian-2

(local)$ nc -nv <gateway_pub> 2222
(UNKNOWN) [<gateway_pub>] 2222 (?) open
XkZ?NK>-h5xs#/OSF
SU6Jv
6%n[;
M5I'R8.W}wgE?"DhADl"jp"$x#4;Z
wT%mJK_l5(Nf]Iw_
$2'ZUmQ2YgdyXnI,
\7_c.f4@bQHcY>N'y
[...]
```

---

<!--config:
margins:
    left: 10
    right: 10
-->

# tmux - **t**erminal **mu**ltiple**x**er

tmux can be used to keep interactive shell tasks running while you're disconnected

* Installation: `$ sudo apt install tmux`
* Create a tmux session: `$ tmux`
* List tmux sessions: `$ tmux ls`
* Attach to first session: `$ tmux a`
* Attach to session by index #: `$ tmux a -t 1`
* Commands inside a session:
    + `Ctrl-b d`: detach from session
    + `Ctrl-b c`: create new window
    + `Ctrl-b n` / `Ctrl-b p`: switch to next/previous window
    + `Ctrl-b %` / `Ctrl-b "`: split window vertically/horizontally
    + `Ctrl-b <arrow keys>`: move cursor across window panes
    + `Ctrl-[ + <arrow keys>`: browse current pane backlog, press return to quit

* Documentation: `$ man tmux`

---

<!--config:
margins:
    left: 4
    right: 10
-->

# References

* [OpenSSH](https://www.openssh.com)
* [SSH History (Wikipedia)](https://en.wikipedia.org/wiki/Secure_Shell)
* [SSH Mastery by Michael W. Lucas](https://mwl.io/nonfiction/tools#ssh)
* [SSH Mastery @BSDCAN 2012](https://www.bsdcan.org/2012/schedule/attachments/193_SSH%20Mastery%20BSDCan%202012-public.pdf)
* [A Visual Guide to SSH Tunnels](https://iximiuz.com/en/posts/ssh-tunnels/)
* [SSH Kung Fu](https://blog.tjll.net/ssh-kung-fu/)
* [The Hacker's Choice SSH Tips & Tricks](https://github.com/hackerschoice/thc-tips-tricks-hacks-cheat-sheet#ssh)
* [Why port 22 ?](https://www.ssh.com/academy/ssh/port)

---

<!--config:
margins:
    top: auto
    left: auto
    right: auto
-->

**Thanks for your attention !**

