# Own CA Ansible playbook

Here is Ansible playbook to create our own CA (and alter) sign certificates with that CA.

# Setup

- First install Ansible following parent [../README.md](../README.md)
- next copy:
  ```shell
  sudo cp template/ansible-vars.yaml /etc/opt/
  ```
- next replace text `REPLACE_WITH_OUTPUT_FROM_ABOVE_COMMAND` in file `/etc/opt/ansible-vars.yaml`
  with output of command `openssl rand -base64 20`
- keep above file `/etc/opt/ansible-vars.yaml` *secret* and in safe location!

Now run validation of all YAML files (should run without error):
```shell
./check-yaml.sh
```

Next invoke `./run.sh 10-create-ca.yaml`, it will:
- generate encrypted private key for our CA in file `/etc/ssl/private/ansible-ca.key`
- generate our CA Certificate in `/usr/local/share/ca-certificates/ansible-ca.crt`
- to make this CA trusted you should run `update-ca-certificates -v`
- it should report

  ```
  ...
  link ansible-ca.pem -> d11e26ad.0
  ...
  1 added, 0 removed; done.
  ```
- you can print content of our CA certificate with:

  ```shell
  openssl x509 -in /usr/local/share/ca-certificates/ansible-ca.crt -text -noout | sed -n '1,/Modulus/p'
  ```

Now we have to create certificate for our WWW server using:
```shell
# CA bundle must be removed to be recreated
sudo rm -f /etc/ssl/certs/ansible-www-bundle.crt
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
  sudo apt-get install nginx
  ```
- create file `/etc/nginx/sites-available/ssl` with contents:

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

