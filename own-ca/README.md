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
./run.sh 20-sign-cert.yaml
```

You can then use for your web server:
- private key:  `/etc/ssl/private/ansible-www.key`
- certificate: `/etc/ssl/certs/ansible-www.crt`
- bundle: recommended that Web server will provide both certificates and CA certs (from leaf to root)
  - you can create bundle with:
    ```shell
    cat /etc/ssl/certs/ansible-www.crt /usr/local/share/ca-certificates/ansible-ca.crt \
       > /etc/ssl/certs/anwble-www-bundle.crt
    ```

How to use in your Web server:
- TODO
