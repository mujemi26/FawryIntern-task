```markdown
# Troubleshooting: Internal Web Dashboard Unreachable (DNS & Network Issues)

## 📌 Scenario
Your internal web dashboard (`internal.example.com`) is suddenly unreachable from multiple systems. Users report "host not found" errors, even though the service is running. This guide will help you systematically diagnose and resolve the issue.

## 🔍 Steps to Troubleshoot & Resolve

### 1️⃣ Verify DNS Resolution
First, check how the domain resolves using the internal resolver (`/etc/resolv.conf`) and a public DNS (e.g., Google’s `8.8.8.8`).

#### 🔹 Commands:
```sh
# View current resolver settings
cat /etc/resolv.conf

# Test resolution using the default resolver
dig internal.example.com

# Test resolution via Google’s public DNS (8.8.8.8)
dig @8.8.8.8 internal.example.com
```

#### 🔹 Expected Output:
- If `dig @8.8.8.8` succeeds but `dig internal.example.com` fails, the issue is with the internal DNS.
- If both fail, there may be a broader network issue.

---

### 2️⃣ Check Service Reachability
Even if DNS is resolving, the web service must be accessible on its assigned port (80 for HTTP, 443 for HTTPS).

#### 🔹 Commands:
```sh
# Test connectivity with curl
curl -I http://internal.example.com
# Test connectivity directly via IP (replace <IP> with resolved address)
curl -I http://<IP>
```
![](./screenshots/curlIP.PNG)
```
# Check if the service is listening
sudo ss -tulpn | grep -E ':80|:443'

# Use telnet/netcat for additional verification
telnet internal.example.com 80
nc -vz internal.example.com 80
```

#### 🔹 Expected Output:
- If direct IP access works but domain access fails ➝ DNS issue.
- If both fail ➝ Possible firewall, routing, or service-level problems.

---

### 3️⃣ Identify Possible Causes
Consider all layers of the network and service setup:

#### 🔹 DNS-Level Issues:
- Misconfigured `/etc/resolv.conf`
- Internal DNS server failures or misconfigured zone files
- Corrupt local DNS cache
- Conflicting `/etc/hosts` entry

#### 🔹 Network-Level Issues:
- Firewall blocking DNS or HTTP/HTTPS traffic
- Routing/NAT misconfiguration
- Web service binding incorrectly (e.g., bound to localhost)

#### 🔹 Service-Level Issues:
- Web server misconfiguration (virtual host, missing ports)
- TLS/SSL misconfigurations causing HTTPS errors

---

### 4️⃣ Apply Fixes

#### 🔹 **Fix: DNS Configuration**
```sh
# Temporary fix: Use a public DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Persistent fix using systemd-resolved
sudo nano /etc/systemd/resolved.conf
# Modify:
[Resolve]
DNS=8.8.8.8 8.8.4.4
FallbackDNS=1.1.1.1 1.0.0.1

# Restart service
sudo systemctl restart systemd-resolved
```

#### 🔹 **Fix: Internal DNS Server**
```sh
# Check DNS server status
sudo systemctl status bind9

# Restart DNS server
sudo systemctl restart bind9
```

#### 🔹 **Fix: Flush Local DNS Cache**
```sh
sudo systemd-resolve --flush-caches
```

---

### 5️⃣ Bonus: Bypass DNS with `/etc/hosts`
For quick testing, override DNS resolution:

#### 🔹 Commands:
```sh
# Open the hosts file
sudo nano /etc/hosts

# Add an entry (replace <IP>)
192.168.1.10 internal.example.com

# Save and test:
ping internal.example.com
```

---

### ✅ Final Verification
After applying fixes, confirm resolution:

#### 🔹 Commands:
```sh
# Test DNS resolution
dig internal.example.com
ping internal.example.com

# Test web service availability
curl -I http://internal.example.com
```

---

## 🏆 Conclusion
By systematically verifying DNS resolution, network access, and service configuration, you can pinpoint the cause of an unreachable web service and resolve it effectively.

If the issue persists, consider deeper network tracing (`traceroute`), reviewing firewall rules, or checking application logs (`/var/log/syslog`).

---


