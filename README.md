# tunneldigger-blacklist

## Beschreibung
Mit diesem Repository wird eine Blacklist für den Tunneldigger-Broker auf
unseren Gateways realisiert. Knoten, welche in der Datei blacklist.txt
aufgeführt sind, können sich nicht mehr per Tunneldigger mit den Gateways
verbinden.

Auf der Blacklist landen Knoten ausschließlich aus technischen Gründen. Leider
ist der Tunneldigger empfindlich bei Fehlkonfigurationen u.ä., was z.B. zu hoher
Last auf allen Gateways bis zu deren Absturz führen kann. Um die Gesamtfunktion
unseres Netzes nicht zu gefährden, muß in diesen Fällen zu solch drastischen
Mitteln (aussperren von Knoten) gegriffen werden. Um das jederzeit
nachvollziehbar zu machen, ist dieses Repository öffentlich einsehbar.

Wer seine Knoten von dieser Liste entfernt haben möchte, kann sich über die
verschiedenen Kommunikationswege (Forum, E-Mail, Kontaktformular, Matrix...)
an unsere Administratoren wenden. Diese werden bei der Beseitigung der helfen,
welcher zum Blacklisten geführt haben. Schnelle Abhilfe kann durch Umstellung des
Knotens von Tunneldigger auf Fastd (dem Default-Verfahren) geschaffen werden.

## Installation
Auf dem Gateway erfolgt im Verzeichnis mit der Konfiguration des
Tunneldigger-Brokers (meist /etc/tunneldigger/ggrz) das Klones dieses
Repositories:
```
cd /etc/tunneldigger/ggrz
git clone https://github.com/ffggrz/tunneldigger-blacklist.git blacklist
```
Das automatische Update geschieht mit folg. Cron-Script:

```
#!/bin/bash

# tunneldigger blacklist configuration directory
CONF_DIR=/etc/tunneldigger/ggrz/blacklist

function getCurrentVersion() {
# Get hash from latest revision
  git log --format=format:%H -1
}

cd $CONF_DIR

# Get current version hash
GIT_REVISION=$(getCurrentVersion)

# Automagically commit local changes
# This preserves local changes
git commit -m "CRON: auto commit"

# Pull latest changes from upstream
git fetch
git merge origin/master -m "Auto Merge"

# Get new version hash
GIT_NEW_REVISION=$(getCurrentVersion)

echo "old: $GIT_REVISION"
echo "new: $GIT_NEW_REVISION"

if [ $GIT_REVISION != $GIT_NEW_REVISION ]
then
  echo "Blacklist updated."
fi
```

Das Script session-up-blacklist-ip.sh wird in der Konfiguration des
Tunneldigger Brokers als session.up Script eingebunden.

Nach Entfernen eines Knotens wird dessen zuletzt verwendete IP-Adresse nicht
automatisch aus den iptables Blockrules entfernt. Das muß auf jedem Gateway von
Hand mit folg. Befehlen erfolgen:

```
iptables -D INPUT -s <IP-Adresse> -j DROP -m comment --comment "<Knotenname>"
```

IP-Adresse und Knotenname findet man so heraus:
```
iptables -L -n
```
