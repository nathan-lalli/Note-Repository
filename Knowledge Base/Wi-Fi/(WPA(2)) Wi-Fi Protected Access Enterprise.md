---
tags:
  - knowledge-base
  - airmon-ng
  - airodump-ng
  - wpa
  - aireplay-ng
  - wireshark
  - tshark
  - crEAP
  - air-hammer
category: wifi
---

# Overview

Wi-Fi Protected Access (WPA), Wi-Fi Protected Access 2 (WPA2), and Wi-Fi Protected Access 3 (WPA3) are security certification programs developed by the Wi-Fi Alliance after the year 2000 to secure wireless networks. These standards were introduced in response to significant vulnerabilities discovered in the earlier Wired Equivalent Privacy (WEP) system.

- `WPA (Wi-Fi Protected Access)`: Introduced as an interim improvement over WEP, WPA offers better encryption through TKIP (Temporal Key Integrity Protocol), but it is still less secure than newer standards.
- `WPA2 (Wi-Fi Protected Access II)`: A significant advancement over WPA, WPA2 uses AES (Advanced Encryption Standard) for robust security. It has been the standard for many years, providing strong protection for most networks.

WPA has two modes:

- `WPA-Personal`: It uses pre-shared keys (PSK) and is designed for personal use (home use).
- `WPA-Enterprise`: It is especially designed for organizations.

## WPA/WPA2 Personal (PSK)

Wi-Fi Protected Access (WPA) Personal was created to replace Wired Equivalent Privacy (WEP). WPA originally implemented the Temporal Key Integrity Protocol (TKIP), which used a dynamic per-packet key to address WEP's vulnerabilities, particularly those involving initialization vector attacks. In addition, WPA introduced Message Integrity Checks (MICs), improving security over the Cyclic Redundancy Checks (CRCs) used by WEP. WPA2 introduced support for CCMP and AES encryption modes, to provide more secure communications.

Although WPA/WPA2 Personal does not support some of the more robust security features seen in WPA/WPA2 Enterprise, it is still widely used for residential routers and in some business settings. Due to the nature of a re-used pre-shared key (Wi-Fi Password), it omits certain protections that are standard in more secure wireless environments. Some of the common methods for capturing the pre-shared key include `Handshake Capture`, `PMKID Capture`, `Wi-Fi Protected Setup`, and `Evil-Twin/Social Engineering` related attacks. With these techniques, an adversary will likely be able to retrieve the clear text version of the pre-shared key and subsequently compromise the wireless network.

## WPA/WPA2 Enterprise (MGT)

Wi-Fi Protected Access Enterprise was developed to meet the need for stronger wireless encryption standards. By utilizing 802.1X security, WPA Enterprise offers more secure communication through the Extensible Authentication Protocol (EAP). Unlike its personal counterpart, WPA/WPA2 Enterprise relies heavily on authentication methods, with one of the key differences being its use of a `RADIUS` server for authentication.

The standard employs Extensible Authentication Protocol-Transport Layer Security (EAP-TLS) to provide better encryption for client devices. WPA Enterprise offers various configuration options to accommodate different use cases, providing flexibility for network administrators. It also addresses vulnerabilities associated with pre-shared key attacks, such as dictionary and brute-force attacks, by supporting diverse authentication methods. However, misconfigurations and inherent design flaws have exposed vulnerabilities in the enterprise standard, making it susceptible to attacks such as evil-twin attacks (used to capture authentication hashes) or security-downgrading of client in order to retrieve plaintext credentials.

# WPA Enterprise

WPA/WPA2 Enterprise (MGT) is a robust security protocol that provides secure wireless access for organizations by leveraging individual user authentication, RADIUS integration, and various EAP methods. Its ability to centralize user management and ensure secure credential transmission makes it a preferred choice for enterprise environments, despite its complexity and associated costs. By implementing WPA Enterprise, organizations can significantly enhance their wireless network security and protect sensitive data from unauthorized access. On a WPA2-Enterprise network, all devices have their own unique set of credentials to access the network instead of sharing a single password. Because routers can’t store all these sets of login information, an authentication server called a RADIUS server is required. The RADIUS server verifies that the credentials of each user are valid by referencing a separate directory with user and device information.

WPA/WPA2 Enterprise utilizes 802.1x authentication in order to authenticate clients to the network. The process generally involves two key steps:

1. `Open System Authentication (Authentication and Association)`
2. `802.1x Authentication through either EAP, PEAP, or TTLS`

The key difference between WPA-Personal and WPA-Enterprise lies in how session keys are handled. In WPA-Enterprise, the initial connection process involves three parties: the `client`, the `access point`, and the `RADIUS` server, which work together to negotiate a unique session key for establishing a secure data connection. Unlike WPA-Personal, which relies on a common pre-shared key, WPA-Enterprise assigns each user a unique session identity, making the process more secure. Consequently, cracking WPA-Enterprise differs from cracking WPA/WPA2-Personal, where methods like capturing the `PMKID` or `EAPOL` (4-Way Handshake) are commonly used. In WPA-Enterprise, each user is authenticated with their own unique `username` and `password`.

## Authentication Framework

In WPA/WPA2-Enterprise, the authentication framework used is known as EAP (Extensible Authentication Protocol).

### Extensible Authentication Protocol (EAP)

Extensible Authentication Protocol (EAP) is a framework widely used in wireless networks and point-to-point connections to provide a flexible method for authentication. Instead of defining a specific way to authenticate, EAP supports a variety of authentication methods or "types," allowing it to adapt to different security requirements. EAP is often used in WPA/WPA2-Enterprise environments where authentication is more complex and robust than just using a pre-shared key (PSK). EAP is not a standalone protocol but a framework that allows for different authentication methods. It operates over lower-layer protocols like IEEE 802.1X, making it suitable for network access authentication.

## Authentication Methods

There are numerous authentication methods available in WPA2 enterprise environment, but the most commonly used in major organizations are PEAP, TTLS, and TLS. These methods are favored for their robust security and effectiveness in protecting sensitive information during authentication processes.

### Protected Extensible Authentication Protocol (PEAP)

Protected Extensible Authentication Protocol (PEAP) is an extension of the Extensible Authentication Protocol (EAP) designed to provide enhanced security for user authentication in wireless networks. PEAP is widely used in WPA/WPA2-Enterprise environments, where it creates a secure, encrypted tunnel between the client and the authentication server before transmitting credentials.

Two Phases of PEAP Authentication:

1. `Phase 1 (Outer Authentication)`: PEAP begins by establishing a TLS tunnel, ensuring that the communication between the client and the server is encrypted. This phase requires the server to have a digital certificate to authenticate itself to the client.
2. `Phase 2 (Inner Authentication)`: Once the encrypted tunnel is established, PEAP transmits the user’s actual authentication credentials securely through this tunnel. Common methods used in this phase include:

- `EAP-MSCHAPv2`: A popular method using username and password for authentication.
- `EAP-GTC`: Allows token-based authentication.

### Tunneled Transport Layer Security (TTLS)

Tunneled Transport Layer Security (TTLS) is an authentication protocol that extends the functionality of the Extensible Authentication Protocol (EAP). Like Protected EAP (PEAP), TTLS establishes a secure, encrypted tunnel between the client and the authentication server before transmitting user credentials. It is primarily used in enterprise environments for wireless and wired network authentication, providing flexibility in the choice of inner authentication methods.

### Transport Layer Security (TLS)

TLS (Transport Layer Security) employs Public Key Infrastructure (PKI) to authenticate clients and servers, ensuring a secure connection to a RADIUS authentication server or other types of authentication servers. This method is widely recognized for its robust security, as it requires both the client and server to present valid `digital certificates` during the authentication process. It is commonly used in high-security environments, such as enterprises and government organizations, where strong security is essential.

## 802.1x Authentication Types

There are two types of authentication in WPA-Enterprise:

1. `Username & Password Authentication (UPA)`: This method requires users to authenticate using a unique username and password combination.
2. `Certificate-Based Authentication (CBA)`: In this approach, authentication is done using digital certificates, which are typically issued to users or devices to ensure secure access.

### Username & Password Authentication (UPA)

In WPA/WPA2-Enterprise, Username and Password Authentication (UPA) is implemented through specific authentication frameworks that support the use of credentials (username and password) for network access. This is typically achieved using protocols like EAP, PEAP, or EAP-TTLS, which encapsulate username and password exchanges within a secure tunnel, protecting them from eavesdropping or interception during the authentication process.

Here is a table showing different authentication types for WPA-Enterprise based on EAP (Extensible Authentication Protocol):

| Method              | Description                                                                                                                                                                                                                                                    |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `EAP-FAST`          | It utilizes a Protected Access Credential (PAC) to establish a secure TLS tunnel for verifying client credentials.                                                                                                                                             |
| `EAP-GTC`           | It involves a text challenge issued by the authentication server, accompanied by a response generated by a security token.                                                                                                                                     |
| `EAP-MD5`           | It is unique among EAP methods as it only authenticates the EAP peer to the EAP server, lacking mutual authentication between the two parties.                                                                                                                 |
| `EAP-MSCHAPv2`      | It requires both the client and the RADIUS server to demonstrate knowledge of the user's password for the authentication process to be successful.                                                                                                             |
| `PEAP-MD5`          | It enables a RADIUS server to authenticate LAN stations by verifying an MD5 hash of each user's password.                                                                                                                                                      |
| `PEAP-GTC`          | It was developed by Cisco to ensure interoperability with existing token card and directory-based authentication systems through a secure, protected channel.                                                                                                  |
| `PEAP-MSChapV2`     | It is one of the most widely used forms of PEAP. It employs MSCHAPv2, allowing it to authenticate against databases that support this format, such as Microsoft NT and Microsoft Active Directory.                                                             |
| `TTLS-PAT`          | It allows the client to initiate the authentication process by tunneling the User-Name and User-Password Attribute-Value Pairs (AVPs) to the TTLS server.                                                                                                      |
| `TTLS-CHAP`         | It securely tunnels client password authentication within TLS records. The client initiates the MS-CHAP process by sending the User-Name, MS-CHAP-Challenge, and MS-CHAP.                                                                                      |
| `TTLS-MSCHAP`       | It securely tunnels client password authentication and the MSCHAP response within TLS records. The client initiates the MS-CHAP process by tunneling the User-Name, MS-CHAP-Challenge, and MS-CHAP-Response Attribute-Value Pairs (AVPs) to the TTLS server.   |
| `TTLS-MSCHAPv2`     | It securely tunnels client password authentication and the MSCHAPv2 response within TLS records. The client initiates the MS-CHAP process by tunneling the User-Name, MS-CHAP-Challenge, and MS-CHAP-Response Attribute-Value Pairs (AVPs) to the TTLS server. |
| `TTLS-EAP-MD5`      | It securely tunnels the MD5 hash within the TLS records for client authentication.                                                                                                                                                                             |
| `TTLS-EAP-GTC`      | It securely tunnels the GTC token within the TLS records for authentication purposes.                                                                                                                                                                          |
| `TTLS-EAP-MSCHAPv2` | It securely tunnels client password authentication and the MSCHAPv2 response within TLS records. The client initiates the MS-CHAP process by tunneling the User-Name, MS-CHAP-Challenge, and MS-CHAP-Response Attribute-Value Pairs (AVPs) to the TTLS server. |

### Certificate Based Authentication (CBA)

Certificate-Based Authentication (CBA) in WPA/WPA2-Enterprise is a robust authentication method that enhances security by utilizing digital certificates to authenticate users and devices connecting to a network. Unlike Username and Password Authentication (UPA), which relies on user credentials, CBA uses cryptographic certificates to establish trust between the client and the network.

| Method         | Description                                                                                                                                                                                                                                                                                     |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `EAP-TLS`      | It is an open standard that employs the TLS (Transport Layer Security) protocol to secure communications. It utilizes Public Key Infrastructure (PKI) for authenticating clients and servers, ensuring a secure connection to a RADIUS authentication server or similar authentication systems. |
| `PEAP-TLS`     | It is similar to EAP-TLS but offers enhanced security by encrypting portions of the certificate that are unencrypted in EAP-TLS.                                                                                                                                                                |
| `TTLS-EAP-TLS` | It securely tunnels the EAP-TLS certificate within TLS records, ensuring that the certificate remains protected during the authentication process.                                                                                                                                              |

## Attacking WPA/WPA2 Enterprise Authentication

There are two main ways to attack WPA-Enterprise:

1. `Brute-force Attack`: This method involves systematically guessing the username and password to crack the network. Attackers use automated tools to try multiple combinations until the correct credentials are found.
2. `Evil Twin Attack`: In this method, attackers set up a rogue access point (evil twin) that mimics the legitimate network. When users connect to the fake access point, their credentials can be captured. If the network uses UPA (Username & Password Authentication), attackers can retrieve either clear-text credentials or hashed passwords. For networks using CBA (Certificate-Based Authentication), attackers can still perform other types of attacks—such as hosting fake captive portals or phishing pages, DNS spoofing, or SSL stripping—once the client connects to the rogue access point with a certificate.

To perform a brute-force attack on a WPA2-Enterprise network, tools such as Air-Hammer or EAPHammer can be utilized effectively. If the brute-force attack fails, the next step to effectively retrieve credentials from end users is to implement an evil-twin attack with a RADIUS server. Our objective is to replicate as many attributes as possible from the target network, enabling clients to connect to our network and undergo the same authentication process they would with the legitimate access point. During this process, users must disclose their identity (user ID) and hashed password to join the network. Cracking the hashed password is typically faster and more practical than attempting to crack the Client Session Key (CSK).

There are many aspects to consider when employing the evil-twin attack that could allow it to be more effective. These are:

1. `How close are we physically to the targeted station (client/victim)?`
2. `What 802.1x authentication method is the access point using?`
3. `Is the access point using client-side SSL certificates (EAP-TLS/PEAP-TLS/TTLS-EAP-TLS)?`
4. `Is there a wireless intrusion detection or prevention system that will detect our actions?`

## Reconnaissance

WPA Enterprise is built on the 802.1X framework, which utilizes RADIUS and EAP (Extensible Authentication Protocol) to provide robust authentication for mid-sized enterprise networks. When scanning for available Wi-Fi networks with tools like `airodump-ng`, encountering an authentication type labeled as `MGT` indicates that the network is configured with WPA Enterprise.

Start monitor mode

```bash
sudo airmon-ng start wlan0
```

Start scan/capture

```bash
sudo airodump-ng wlan0mon -c 1
```

### PMK Caching and PMKID

The Pairwise Master Key Identifier (PMKID) is a unique identifier generated during the security association between a client and an access point (AP) using the Pairwise Master Key (PMK). PMKID plays a crucial role in facilitating faster reconnections for clients. When a client initially connects to an AP (let’s call it AP1) and later moves out of its range, the PMKID allows the client to skip the full EAP handshake if it reconnects to the same AP (AP1). This is achieved by including the cached PMKID in the (Re)association request when the client returns within the range of AP1, streamlining the reconnection process. The PMKCacheTTL, which determines how long a Pairwise Master Key (PMK) is stored in the cache, has a default value of 720 minutes according to [Microsoft](https://learn.microsoft.com/en-us/uwp/schemas/mobilebroadbandschema/wlan/element-pmkcachettl). This setting applies to WPA2 networks where PMKCacheMode is enabled, and it can be adjusted to any value between 5 and 1440 minutes.

From an EAP handshake, we can extract several critical details, including the `username`, `domain name`, and `handshake certificate`. If PMK caching is disabled on the access point (AP), we can force clients to perform a full EAP handshake by carrying out a de-authentication attack, disconnecting them, and prompting a reconnect. However, if PMK caching is enabled, we would need to wait for the PMK cache to expire before clients are required to complete a full EAP handshake again. The cache expiration time can range from 5 to 1440 minutes, depending on the configured PMKCacheTTL value.

> [!NOTE] A full EAP handshake will be captured through a de-authentication attack only if the PMK cache is disabled on the access point (AP). If PMK caching is enabled, the client may use the cached PMKID to reconnect without performing the full EAP handshake. In this case, the handshake capture will not occur, and we would have to wait for the PMK cache TTL to expire.

To start capturing WPA handshake data, we can use `airodump-ng` with the `-w WPA` argument to save the scan output into a file with the WPA prefix. This process will create a `WPA-01.cap` file, which will automatically update with new data as the scan continues.

```bash
sudo airodump-ng wlan0mon -c 1 -w WPA
```

Start the de-auth to capture the handshake

```bash
sudo aireplay-ng -0 1 -a XX:XX:XX:XX:XX:XX -c XX:XX:XX:XX:XX:XX wlan0mon
```

Once we have captured the WPA handshake, we can use the `WPA-01.cap` file to extract important details such as the username, domain name, and handshake certificate from the captured data.

### Finding the Domain and Username

To identify the username used by the client, we can open the `WPA-01.cap` file in Wireshark and apply a filter for `eap`. This will show packets related to the Extensible Authentication Protocol (EAP).

We can look for a packet labeled as `Response, Identity`. Within this packet, we should see the username in the format `Domain\Username`.

We can also use [tshark](https://www.wireshark.org/docs/man-pages/tshark.html) to extract potential usernames from the WPA-01.cap file. The following command demonstrates how this can be done:

```bash
tshark -r WPA-01.cap -Y '(eap && wlan.ra == XX:XX:XX:XX:XX:XX) && (eap.identity)' -T fields -e eap.identity
```

Another effective tool for extracting domain and username information from clients is [crEAP](https://github.com/p0dalirius/crEAP). This tool works by utilizing airodump-ng in the background to scan for valid EAP handshakes. Once a valid handshake is detected, crEAP automatically extracts the username and domain information and presents it.

```bash
git clone https://github.com/p0dalirius/crEAP.git
```

```bash
python2.7 ./crEAP.py
```

If we’re not able to capture any valid user information after some time, we can perform a de-authentication attack to force clients to reconnect to the access point. If the access point has PMKID caching disabled, this will prompt a full EAP handshake, allowing crEAP to capture and display the username and domain name.

### EAP-PEAP and Anonymous Identities

In some enterprise environments, when the client responds with an identity, we may notice that it looks like anonymous or anonymous@something_x. In this case, the client and access point are anonymizing identities. This makes it much more difficult for us to retrieve the username along with the password (in the hash or plaintext form) later on. This is handled differently per EAP/PEAP method.

For another perspective on anonymous identities, this article is a great resource: [EAP-PEAP and EAP-TTLS Authentication](https://www.interlinknetworks.com/app_notes/eap-peap.htm).

#### EAP-Identity = anonymous

In Wireshark, if we notice that the first identity response indicates the username `anonymous`, it means our network supports anonymous identities. Essentially this works like the following:

1. The first phase allows the establishment of the TLS tunnel through EAP-PEAP or EAP-TTLS, in which the anonymous identity is sent to the RADIUS server during the identity request and response steps.
2. Once the TLS tunnel is established, the true user identity is disclosed between the RADIUS server and the client. This effectively allows them to move forward with the remainder of the exchange.

#### EAP-Identity = anonymous@realm_x

Suppose we notice that the identity response is `anonymous@realm_x`. In this case, users are relegated to different realms, which indicate the RADIUS servers where their true identities reside. This process can be broken up like the following:

1. The first phase allows the establishment of the TLS tunnel through EAP-PEAP or EAP-TTLS. However, this time the identity includes the realm which their RADIUS server resides in. At this point, the communications occur between these users and the realm RADIUS as a proxy.
2. The remainder of the requests to finish authentication are then conducted between the client and the respective RADIUS server to finish 802.1x authentication.

### Obtaining the Certificate

To establish a TLS tunnel between the management network and a client, the access point (AP) sends its certificate to the client in clear text, which means it can be intercepted by anyone. This certificate contains valuable information that can be leveraged to create a fake certificate with matching fields for a Rogue AP attack. Additionally, it can reveal details about the corporate domain, internal emails, and other relevant information about the AP.

To obtain the handshake certificate in Wireshark, we can apply the filter.

```wireshark
(wlan.sa == XX:XX:XX:XX:XX:XX) && (tls.handshake.certificate)
```

This filter focuses on the AP's BSSID to isolate the relevant packet containing the certificate. The extracted certificate can provide valuable information about the access point.

We can also use the [pcapFilter.sh](https://gist.githubusercontent.com/r4ulcl/f3470f097d1cd21dbc5a238883e79fb2/raw/78e097e1d4a9eb5f43ab0b2763195c04f02c4998/pcapFilter.sh) bash script to automatically extract the handshake certificate from a packet capture, which uses `tshark` to extract the certificate and copy it to the `/tmp/certs` directory.

```bash
wget https://gist.githubusercontent.com/r4ulcl/f3470f097d1cd21dbc5a238883e79fb2/raw/78e097e1d4a9eb5f43ab0b2763195c04f02c4998/pcapFilter.sh
```

```bash
./pcapFilter.sh -f WPA-01.cap -C
```

The extracted certificate reveals several critical details, such as `C=country, ST=state, L=locale, O=origin, CN=canonical name`. These details are invaluable when setting up our fake access point, as they allow us to configure it to closely mimic the legitimate AP, increasing the chances of deceiving clients into connecting.

### Finding Authentication Methods Supported by RADIUS Server

With a valid username in hand, we can use [EAP Buster](https://github.com/blackarrowsec/EAP_buster) to identify the specific EAP methods that the RADIUS server (behind a WPA-Enterprise access point) supports for that user.

```bash
git clone https://github.com/blackarrowsec/EAP_buster.git
```

```bash
sudo ./EAP_buster.sh SSID 'domain\username' wlan0mon
```

Some users might be restricted to a limited set of authentication methods. Therefore, it's advisable to perform an authentication check for all identified users.

## Brute Force Attacks

In WPA-PSK networks, only one password grants access, while WPA Enterprise networks may have thousands of valid username and password combinations. Since the passwords are often chosen by end users, they are frequently simple and vulnerable to brute-force attacks, making WPA Enterprise networks susceptible to such threats.

### Air-Hammer

```bash
git clone https://github.com/Wh1t3Rh1n0/air-hammer.git
```

To execute an attack using `air-hammer`, we must provide the following essential parameters:

- The intended wireless interface.
- The SSID (network name) of the target wireless network.
- A list of usernames to target.
- A single password, or a list of passwords, to be tested against each username.

> [!INFO] The username must include the domain as well e.g. 'Domain\User'

#### Brute Force a User

```bash
echo 'Domain\User' > users.txt
sudo python2.7 air-hammer.py -i wlan0 -e SSID -p wordlist.txt -u users.txt
```

#### Password Spraying

We can create a user list from known names in the target organization, statistically likely names, default lists, etc. then throw passwords at them to see if we get a hit.

We will need to add the domain to the user names, we can use `awk` for this.

```bash
cat possibleusers.txt | awk '{print "Domain\\" $1}' > users.txt
```

Now that we have a users list we can use `air-hammer` to pass a password list or a single password to attempt login

`Try a single password 'Password123' against the users.txt list`
```bash
sudo python2.7 air-hammer.py -i wlan0 -e SSID -P Password123 -u users.txt
```

`Try a list of passowrds against the users.txt list`
```bash
sudo python2.7 air-hammer.py -i wlan0 -e SSID -p rockyou.txt -u users.txt
```

> [!INFO] When using a password list it will try the first password in the list for each user before moving on to the next password

