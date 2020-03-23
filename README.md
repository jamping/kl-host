# kl-host
klasa.lokalni.pl - BigBlueButton docker instance

# How to build it
```docker build . -t kl-host```

# How to start it?

```
docker run --rm -p 443:443/tcp -p 16384-32768:16384-32768/udp kl-host -h providername-01.conf.klasa.lokalni.pl
```