#cloud-config
ssh_pwauth: true
chpasswd:
  expire: false
  users:
  - name: ${build_username}
    password: ${build_password}
    type: text
write_files: 
- path: /etc/netplan/50-cloud-init.yaml
  content: |
    network:
      version: 2
      ethernets:
        ens3:
          dhcp4: true
- path: /etc/ssh/sshd_config
  content: |
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedKeyTypes +ssh-rsa
  append: true
- path: /etc/pam.d/common-session
  content: |
    session optional 	pam_mkhomedir.so
  append: true
runcmd:
- netplan apply
- systemctl restart --no-block sshd.service
