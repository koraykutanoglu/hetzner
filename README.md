# Test Otomasyonu

brew install hcloud

hetzner cloud tarafından api key alıyorsun.

(komutu girdikten sonra token giriyorsun)
hcloud context create Secops 

ssh-key'i hetzner arayüzünden giriyorsun.
hcloud server create --name test --image ubuntu-20.04 --type cx11 --without-ipv6 --location hel1 --ssh-key mac

hcloud server delete test