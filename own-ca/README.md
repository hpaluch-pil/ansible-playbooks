# Own CA Ansible playbook

Here is Ansible playbook to create our own CA (and alter) sign certificates with that CA.

# Setup

- First install Ansible following parent [../README.md](../README.md)
- for [Void Linux](https://voidlinux.org/) you have to prepare directories:
  ```shell
  mkdir -p /etc/opt/ /etc/ssl/private /usr/local/share/ca-certificates
  chmod 700 /etc/ssl/private
  ```
- next copy:
  ```shell
  # use this path for Debian or Void Linux:
  sudo cp template/debian/ansible-vars.yaml /etc/opt
  # use this path for Fedora:
  sudo cp template/fedora/ansible-vars.yaml /etc/opt
  ```
- next replace text `REPLACE_WITH_OUTPUT_FROM_ABOVE_COMMAND` in file `/etc/opt/ansible-vars.yaml`
  with output of command `openssl rand -base64 20`
- keep above file `/etc/opt/ansible-vars.yaml` *secret* and in safe location!

Now run validation of all YAML files (should run without error):
```shell
./check-yaml.sh
```

Next invoke `./run.sh 10-create-ca.yaml` (or `./run.sh -K 10-create-ca.yaml` if
your `sudo` command requires password), it will:
- generate encrypted private key for our CA in file `/etc/ssl/private/ansible-ca.key`
- generate our CA Certificate in `/usr/local/share/ca-certificates/ansible-ca.crt`
- to make this CA trusted you should run
  - on Debian or Void Linux:  `update-ca-certificates -v`
  - on Fedora: `update-ca-trust`
- on Debian it should report

  ```
  ...
  link ansible-ca.pem -> d11e26ad.0
  ...
  1 added, 0 removed; done.
  ```
- you can print content of our CA certificate with:

  ```shell
  # on Debian or Void Linux:
  openssl x509 -in /usr/local/share/ca-certificates/ansible-ca.crt -text -noout | sed -n '1,/Modulus/p'
  # on Fedora:
  openssl x509 -in /etc/pki/ca-trust/source/anchors/ansible-ca.crt -text -noout | sed -n '1,/Modulus/p'
  ```

Now we have to create certificate for our WWW server using:
```shell
# CA bundle must be removed to be recreated
# on Debian:
sudo rm -f /etc/ssl/certs/ansible-www-bundle.crt
# on Fedora:
sudo rm -f /etc/pki/tls/certs/ansible-www-bundle.crt
# common: add "-K" in the middle if your sudo requires password:
./run.sh 20-sign-cert.yaml
```

You can then use for your web server:
- web private key:  `/etc/ssl/private/ansible-www.key`
- web certificate (normally not used alone): `/etc/ssl/certs/ansible-www.crt`
- CA bundle (contains web certificate + CA certificate): `/etc/ssl/certs/ansible-www-bundle.crt`
  - it is preferred when web server returns CA bundle that contains not just
    certificate but also all CA certificates in chain, so browser can validate
    it without fetching CA certificates from Internet (without bundle, many browsers
    will simply treat such certificate as not trusted)

How to use in your Web server:
- example for Debian:
- install stock nginx web server with:
  ```shell
  # on Debian:
  sudo apt-get install nginx
  # on Void Linux:
  sudo xbps-install -u nginx
  ```
- on Void Linux just append `443` section below to `/etc/nginx/nginx.conf`
  (there is template, but commented out)
- on Debian create file `/etc/nginx/sites-available/ssl` with contents:

```nginx
# /etc/nginx/sites-available/ssl
server {
	# SSL configuration
	listen 443 ssl default_server;
	listen [::]:443 ssl default_server;
	server_name _;
	ssl_certificate /etc/ssl/certs/ansible-www-bundle.crt;
	ssl_certificate_key /etc/ssl/private/ansible-www.key;

	root /var/www/html;
	index index.html index.htm index.nginx-debian.html;

	location / {
		try_files $uri $uri/ =404;
	}
}
```

- enable this `ssl` site using:
  ```shell
  # as root
  cd /etc/nginx/sites-enabled
  ln -s ../sites-available/ssl
  ```
- verify configuration and restart nginx:
  ```shell
  nginx -t
  # on Void Linux:
  ( /etc/runit/runsvdir/default && ln -s /etc/sv/nginx )
  sv restart nginx
 
  # on Debian or Fedora:
  systemctl restart nginx
  ```
- test with local curl - note that it should accept our Web certificate wit our own CA (because
  we added it trusted CA list with `update-ca-certificates` command:
  ```shell
  curl -i https://`hostname -f`
  ```
- when you add `-v` option you can see certificate details:
  ```
  * Server certificate:
  *  subject: [NONE]
  *  start date: Apr 15 11:52:21 2025 GMT
  *  expire date: Apr 16 11:52:21 2026 GMT
  *  subjectAltName: host "deb12-ansible.example.com" matched cert's "deb12-ansible.example.com"
  *  issuer: CN=Ansible CA
  *  SSL certificate verify ok.
  ```

NOTE: If you will access nginx remotely, your browser will not trust our
certificate because it does not know our own CA (that signed it). In such case
you have to add our `/usr/local/share/ca-certificates/ansible-ca.crt` to "trust
CA store" on your client machine (on Debian, just copy it to same location and
run `update-ca-certificates`, on other systems such setup varies).

