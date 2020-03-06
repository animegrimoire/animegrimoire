## How does syncthing works?

Syncthing is a decentralized file synchronization tool. It shares similarities with commercial cloud storage products you may be familiar with, like Dropbox or Google Drive, but unlike these cloud storage products, it does not require you to upload your data to a public cloud. It also shares similarities with self-hosted cloud storage platforms like ownCloud or NextCloud, but unlike those products, it does not require a central server of any kind.

Syncthing works off of a peer-to-peer architecture rather than a client-server architecture. Computers attached to your Syncthing network each retain copies of the files in your shared folders and push new content and changes to each other through peer-to-peer connections. Unlike other peer-to-peer software you may be familiar with, like file sharing applications, Syncthing uses a private sharing model and only devices specifically authorized with each other can share files. All communication between the peers is encrypted to protect against man in the middle attacks intercepting your private data. -- ([gigenet](https://www.gigenet.com/blog/how-to-set-up-a-complex-syncthing-network/))

Full documentation about syncing can be reads in Syncthing [Documentation](https://docs.syncthing.net/users/syncing.html) and about Relay server [here](https://docs.syncthing.net/users/strelaysrv.html)
<hr>

Too hard? let's break it down to more simple manner.

Basically, Syncthing is a file sync tool (like google drive/dropbox app), but instead we put it in Big Brothers storage, we're hosting it on our own server. File are sent using P2P method **but** that doesn't means you have to *seed* files like traditional torrent files.

It's just You and Me. I send files, and You receive files. Sender and Receiver won't get mixed up as we have our own ID. Simple as.

Let's see this illustration to explain that you're only downloading files, without needing to upload them.

<div align="center">
<img src="https://i.ibb.co/y0zBk6L/syncthing.jpg" alt="Animegrimoire Syncthing Setup"</img><br>
You're just downloading anime, with extra step
</div>
<br>

So to summary:

1. You're downloading files in one-way from our server to your pc
2. You don't have to *seed* or uploads your file to another downloader
3. It still works even if you're behind NAT or you don't have public IP
4. You only need to do one-time setup per season. Any encoded files will automatically sent to your folder afterwards

<hr>

Is it secure? after reading these sources [[1]](https://forum.syncthing.net/t/can-you-please-convince-me-that-syncthing-is-safe-to-use/11154) [[2]](https://docs.syncthing.net/users/security.html) [[3]](https://www.researchgate.net/publication/279959852_Forensic_Analysis_and_Remote_Evidence_Recovery_from_Syncthing_An_Open_Source_Decentralised_File_Synchronisation_Utility), we conclude that Syncthing is safe to use and it's good for your privacy.
