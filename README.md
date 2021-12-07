# misc
some other random notes that is helpful with day to day troubleshooting


### Redhat CDN 
the certificate is created and downloaded on Redhat Access Network and must be generated with specific version(`7`) and architecture (`x86_64`), the full path to the repomd.xml must also be specified in `curl` command line otherwise would still have the `TCP_DENIED` error

```
curl -kv --cert cert.pem --key cert.key https://cdn.redhat.com/content/dist/rhel/server/7/7Server/x86_64/os/repodata/repomd.xml

< HTTP/1.1 200 OK
< Accept-Ranges: bytes
< Content-Type: application/xml
< ETag: "131c42733a43ef04d8630bbf3cd71df6:1638461927.024233"
< Last-Modified: Thu, 02 Dec 2021 16:09:52 GMT
< Server: AkamaiNetStorage
< Content-Length: 3565
< Date: Tue, 07 Dec 2021 04:03:01 GMT
< X-Cache: TCP_MEM_HIT from a104-71-131-6.deploy.akamaitechnologies.com (AkamaiGHost/10.4.6-37171458) (-)
< Connection: keep-alive
< EJ-HOST: authorizer-prod-dc-iad2-5-2nfcz
< X-Akamai-Request-ID: 24a24eb
<
<?xml version="1.0" encoding="UTF-8"?>
<repomd xmlns="http://linux.duke.edu/metadata/repo" xmlns:rpm="http://linux.duke.edu/metadata/rpm">
  <revision>1638461392</revision>
  <data type="primary">
    <checksum type="sha1">9a2e119d06ef9eb54d387e9b02d2e0ee12946632</checksum>
    <open-checksum type="sha1">7e84c30cfc84496a0e62114d25e75a3a9a38434b</open-checksum>
    <location href="repodata/9a2e119d06ef9eb54d387e9b02d2e0ee12946632-primary.xml.gz"/>
    <timestamp>1638460353</timestamp>
    <size>56459453</size>
    <open-size>409406396</open-size>
  </data>
```

```
curl -kv --cert cert.pem --key cert.key https://cdn.redhat.com/

< HTTP/1.1 403 Forbidden
< Server: AkamaiGHost
< Mime-Version: 1.0
< Content-Type: text/html
< Content-Length: 262
< Expires: Tue, 07 Dec 2021 04:03:24 GMT
< Date: Tue, 07 Dec 2021 04:03:24 GMT
< X-Cache: TCP_DENIED from a104-71-131-14.deploy.akamaitechnologies.com (AkamaiGHost/10.4.6-37171458) (-)
< Connection: keep-alive
< EJ-HOST: authorizer-prod-dc-iad2-5-2nfcz
< X-Akamai-Request-ID: 2c1382d
<
<HTML><HEAD>
<TITLE>Access Denied</TITLE>
</HEAD><BODY>
<H1>Access Denied</H1>

You don't have permission to access "http&#58;&#47;&#47;cdn&#46;redhat&#46;com&#47;" on this server.<P>
Reference&#32;&#35;18&#46;e834768&#46;1638849804&#46;2c1382d
</BODY>
</HTML>
```
