---
tags:
  - knowledge-base
category: linux
---

## Overview

APT is what controls the packages installed on Debian, and a few other, Linux distros.

## Add a Package Repo

### Old Way

If there is a GPG key, download it

```bash
sudo wget -O /usr/share/keyrings/example-repo.gpg https://example.com
```

Only add the 'signed by' portion if there is a GPG key

```bash
sudo echo "deb [signed-by=/usr/share/keyrings/example-repo.gpg] http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list
sudo apt-get update
```

### New Way

Download the GPG key

```bash
sudo wget -O /usr/share/keyrings/example-repo.gpg https://example.com
```

Create a new source file in /etc/apt/sources.list.d/

```bash
sudo cat > /etc/apt/sources.list.d/example.list << 'EOF'
Types: deb
URIs: https://example.com
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/example-repo.gpg
EOF
sudo apt-get update
```

## Exclude Mirrors for a Repository

There are some mirrors for Kali that are blocked by some ISPs, e.g. kali.darklab.sh. To bypass this we can create a preferences list and add that mirror to the list with an APT pinning priority of -1 making it never get used.

```bash
sudo cat > /etc/apt/preferences.d/exclude-mirror.pref << 'EOF'
Package: *
Pin: origin kali.darklab.sh
Pin-Priority: -1
EOF
sudo apt-get update
```

