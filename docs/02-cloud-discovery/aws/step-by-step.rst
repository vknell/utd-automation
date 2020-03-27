=====================================
Activity 1: AWS Deploy your first VPC
=====================================

Architecture de l’infrastructure à déployer sur AWS :

.. figure:: architecture cible.png

Se connecter sur la console AWS

XXXXXXXXXX






Création d’un VPC (Virtual Private Cloud)

Etape 1 : Allez dans Services, faites une recherche sur VPC et choisissez le service VPC :

.. figure:: AWS Console access.png

Etape 2 : Allez à Virtual Private Cloud > Your VPC > Create VPC

.. figure:: Create VPC-1.png

.. figure:: Create VPC-2.png


Etape 3 : Remplissez le nom du VPC, le sous réseau, laissez les autres paramètres par défaut et cliquez sur Save pour sauvegarder :

.. figure:: Create VPC-3.png

Etape 4 : Sélectionnez le VPC MonVPC et allez dans Actions > Edit DNS hostnames

.. figure:: Create VPC-4.png

Etape 5 : Dans Edit DNS hostnames, cochez le bouton enable et sauvegardez

.. figure:: Create VPC-5.png










Création des sous réseaux AWS (subnets)

Le bloc de réseaux IPv4 créé avec le VPC sera maintenant segmenté en plusieurs sous réseaux. Vous pouvez créer des sous-réseaux ayant des plages d’adresses IP qui feront partis du bloc IPv4 du VPC.
Les sous réseaux seront utilisés comme suit :

.. figure:: Create VPC-6.png

Etape 1: allez dans VPC > Subnets > Create subnet

.. figure:: Create VPC-7.png

Etape 2 : Renseignez le nom, le VPC (MonVPC), la zone de disponibilité et la plage du sous réseau en se basant sur le tableau ci-dessus pour le subnet Management_Subnet et sauvegardez la configuration

.. figure:: Create VPC-8.png

Etape 3 : Répétez l’étape précédente pour les deux autres sous réseaux Untrusted_Subnet et Trusted_Subnet

.. figure:: Create VPC-9.png














Création d’une passerelle Internet IGW
La création d’un passerelle Internet est indispensable pour permettre au VPC de se connecter à Internet. Une fois que la passerelle est créée, il sera nécessaire de l’attacher à un VPC.


Etape 1 : Allez dans VPC > Internet Gateways > Create internet gateway et utilisez MonIGW comme nom

.. figure:: Create VPC-10.png

Etape 2 : Sélectionnez l’IGW MonIGW et ensuite allez dans Actions > Attach to VPC


.. figure:: Create VPC-11.png


Etape 3 : Sélectionner le VPC MonVPC et sauvegarder

.. figure:: Create VPC-12.png












Création des tables de routage

Les tables de routage vous permettent d'attribuer une connectivité telle que des passerelles Internet et des passerelles par défaut à des groupes spécifiques de points de terminaison. Rappelez-vous que tous les points d'extrémité dans le VPC peuvent se connecter de manière native à n'importe quel autre point d'extrémité dans le bloc CIDR VPC affecté (exemple : 10.2.0.0/16). Cela ne peut pas être modifié par une table de routage. Il existe une table de routage principale créée par défaut pour un VPC, et tous les sous-réseaux qui ne sont pas affectés à une table de routage personnalisée sont affectés à la table de routage principale du VPC. Par défaut, la table de routage principale route uniquement vers le bloc CIDR VPC. Les tables de routage peuvent contrôler toute connectivité de sous-réseau IP en
dehors du bloc CIDR VPC.

Bien que les tables de routage Untrusted_RT (publique) et Management_RT (table de routage du
subnet de Management) soient programmées de la même manière ci-dessous, elles sont réparties
séparément car vous pouvez personnaliser votre table de routage Management_RT pour accéder
uniquement aux destinations de gestion sélectionnées via l'IGW par rapport à une table ouverte par défaut de 0.0.0.0/0. Il existe une table de routage de serveur Web pour chaque zone de disponibilité et une route par défaut sera ajoutée plus loin dans ce guide, une fois les pare-feux programmés et opérationnels.

Ci-dessous, les tables de routage à créer sont décrites dans le tableau ci-dessous :

.. figure:: Create VPC-13.png

Etape 1 : Créez la table de routage Management_RT en allant vers Services > VPC > Virtual Private Cloud > Routes Tables > Create route table

Etape 2 : Entrez le nom de la table de routage, sélectionnez le VPC MonVPC et sauvegardez

.. figure:: Create VPC-14.png

Etape 3 : Sélectionnez la table de routage Management_RT

.. figure:: Create VPC-15.png

Etape 4 : Allez dans Routes pour ajouter une nouvelle route par défaut en cliquant sur Edit Routes

.. figure:: Create VPC-16.png


Etape 5 : Ajoutez la nouvelle route 0.0.0.0/0, sélectionnez la passerelle MonIGW au niveau du Target et sauvegardez les changements

.. figure:: Create VPC-17.png

Etape 6 : Allez dans Subnet Associations > Edit subnet associations

.. figure:: Create VPC-18.png

Etape 7 : Sélectionnez Management_Subnet et sauvegardez

.. figure:: Create VPC-19.png

Etape 8 : Répétez les étapes 1 à 7 pour créer, modifier la table de routage et associer le subnet pour la table de routage Untrusted_RT


Etape 9 : Créez la table de routage Trusted_RT et associez le subnet Trusted_Subnet à cette dernière.

Attention : Pas de route par défaut pour la table de routage Trusted_RT, cette route par défaut sera ajoutée ultérieurement.












Création des groupes de sécurité (Security Groups)

Lorsque vous créez une instance de calcul AWS Elastic Compute (EC2) pour exécuter une instance de machine virtuelle, vous devez attribuer un groupe de sécurité (SG) nouveau ou existant à cette instance. Les groupes de sécurité fournissent un pare-feu à état de couche 4 pour le contrôle des adresses IP sources/destinations et les ports qui sont autorisés à destination ou en provenance des instances associées. Les SG sont appliqués aux interfaces réseau. Jusqu'à cinq SG peuvent être associés
à une interface réseau. L'accès sortant par défaut est autorisé pour permettre l'ensemble du trafic de sortir vers tous les lieux ; vous pouvez toutefois la personnaliser en fonction de vos opérations. Par défaut, la liste d'accès aux services entrants est définie de manière à ne pas autoriser le trafic ; vous modifierez cette configuration en fonction des tableaux ci-dessous.


Vous configurez les groupes de sécurité à affecter au pare-feu de la VM-Series et au serveur Web :

* Untrusted (interface publique du pare-feu) : Initialement, tout le trafic sera autorisé vers les périphériques du groupe de sécurité publique, par exemple le groupe de sécurité publique du pare-feu, et le pare-feu contrôlera le trafic grâce à des politiques de sécurité. Vous pouvez restreindre l’accès au réseau seulement aux ports de la couche 4 nécessaires. Ce dernier réduira la charge de trafic inutile qui pourra arriver sur l’interface publique du firewall.

*Management du Firewall : autoriser les ports nécessaires pour pouvoir gérer votre firewall
comme l’ICMP, le SSH et le HTTPS

*Serveur Web : Autoriser les flux nécessaires pour les flux de gestion du serveur web et
évidemment les flux web.



Utrusted_SG – inbound rules
.. figure:: Create VPC-20.png

Management_SG – inbound rules
.. figure:: Create VPC-21.png

Trusted_SG – inbound rules
.. figure:: Create VPC-22.png

Etape 1: Allez dans Services > EC2 > NETWORK & SECURITY > Security Groups > Create Security
Group

.. figure:: Create VPC-23.png

Etape 2 : Donnez un nom au SG, une description, associez le SG au VPC MonVPC et ajoutez les règles de sécurité comme indiqué dans l’image suivante

.. figure:: Create VPC-24.png

Etape 3 : Répétez l’étape 2 pour créer le SG Untrusted_SG

.. figure:: Create VPC-25.png

Etape 4 : Répétez l’étape 2 pour créer le SG Trusted_SG

.. figure:: Create VPC-26.png

Au total, trois SG doivent être créés comme suit :

.. figure:: Create VPC-27.png








Création des interfaces réseau pour le firewall virtuel VM-Series

Avant d’installer l’instance de pare-feu virtuel, vous allez créer les interfaces Ethernet1/1 et Ethernet1/2 pour l’associer ultérieurement à la VM-Series.

Etape 1: Allez dans Services > EC2 > Network & Security > Network Interfaces > Create Network
Interface

Etape 2 : Créez l’interface Ethernet1/1 qui est l’interface Untrusted en donnant une description, sélectionnant le subnet Untrusted_Subnet, donnant l’adresse IP 10.2.10.10 et en sélectionnant le Security Group Untrusted_SG

.. figure:: Create VPC-28.png

Etape 3 : Créez l’interface Ethernet1/2 qui est l’interface Trusted en donnant une description, sélectionnant le subnet Trusted_Subnet, donnant l’adresse IP 10.2.5.10 et en sélectionnant le Security Group Trusted_SG


.. figure:: Create VPC-29.png
.. figure:: Create VPC-30.png














Déploiement de la VM-Series 300 dans AWS

Le pare-feu VM-Series sera déployé dans le VPC MonVPC créé précédemment. L’interface de gestion est dans le sous-réseau Management_Subnet. Les sous-réseaux d'adresses IP, les tables de routage et les groupes de sécurité ont été mis en place dans la section précédente pour l'ensemble du VPC et sont utilisés dans cette section.
Dans un premier temps le firewall sera déployé avec une seule interface qui est l’interface de management. Une fois déployé, vous allez lui associer les interfaces créées dans l’étape précédente.

Ci-dessous les paramètres de la VM-Series à déployer :
.. figure:: Create VPC-31.png

Etape 1 : Allez dans Services > EC2 > Instances > Instances > Launch Instance, sélectionnez AWS Marketplace, faites une recherche sur Palo Alto Networks et sélectionnez VM-Series Next-Generation Firewall (BYOL and ELA)

.. figure:: Create VPC-32.png

Etape 2 : Dans Choose Instance Type, cherchez le type m4.xlarge, sélectionnez le et cliquez sur Next:Configure Instance Details


Etape 3 : Dans Configure Instance Details, sélectionnez le VPC MonVPC pour Network, dans Subnet sélectionner Management_Subnet. Dans Auto-assign Public IP, sélectionnez Disable et dans Network Interfaces > Primary IP modifiez le champ pour mettre l’adresse IP 10.2.9.21

.. figure:: Create VPC-33.png

Etape 4: Dans Add Storage, cliquez sur Next Next : Add Tags (aucune modification)

Etape 5 : Dans Add Tags, cliquez sur Next : Configure Security Group

Etape 6 : Dans Configure Security Group, sélectionnez le groupe de sécurité Management_SG, et
cliquez sur Review and Launch
.. figure:: Create VPC-34.png


Etape 7 : Dans Review and Launch, cliquez sur Launch

Etape 8 : Créez une paire de clé publique/clé privée pour pouvoir se connecter en SSH sur le firewall.
Il faut choisir Create a new key pair, donner à un nom (comme MonVPC), télécharger la paire de clés sur votre machine et enfin, lancer le déploiement en cliquant sur Launch Instances

.. figure:: Create VPC-35.png







Création de adresses IP publiques

Etape 1 : Allez dans Services > EC2 > Network & Security > Elastic IP > Allocate Elastic IP Address

Etape 2 : Sélectionnez Amazon’s pool of IPv4 addresses et cliquez sur allocate pour allouer une première adresse publique IPv4

.. figure:: Create VPC-36.png


Etape 3 : Répétez les deux étapes précédentes pour allouer une deuxième adresse IP publique

tape 4 : Sélectionnez une des deux adresses IP publiques, ensuite allez dans Actions > Associate Elastic IP address

.. figure:: Create VPC-37.png

Etape 5 : Sélectionnez Network interface dans Resource type, dans Network Interface sélectionnez l’interface Management du Firewall et dans Private IP address, sélectionnez l’adresse IP privée de Management qui 10.2.9.21

.. figure:: Create VPC-38.png

Etape 6 : Dans cette étape, il faut sélectionner la deuxième adresse IP qui n’est pas encore allouée, ensuite allez dans Actions > Associate Elastic IP Address

Etape 7 : Sélectionnez Network interface dans Resource type, dans Network Interface sélectionnez l’interface Untrusted du Firewall et dans Private IP address, sélectionnez l’adresse IP privée Untrusted qui est 10.2.10.10

.. figure:: Create VPC-39.png








Attacher les interfaces Ethernet1/1 et Ethernet1/2 au Firewall

Etape 1 : Allez dans Services > EC2 > NETWORK & SECURITY > Network Interfaces, Sélectionnez
l’interface Ethernet1/1, cliquez sur Attach, choisissez l’instance du firewall dans Instance ID et cliquez sur Attach

.. figure:: Create VPC-40.png


Etape 2 : Répétez l’étape 1 pour attacher l’interface Ethernet1/2 à l’instance Firewall

.. figure:: Create VPC-41.png








Première connexion à la VM-Series

Par défaut et pour un nouveau déploiement de VM-Series dans AWS, l’instance déployée ne contient pas de mot passe pour le compte admin. Il est donc nécessaire de se connecter en SSH sur le pare-feu en utilisant la paire de clés générée durant l’étape de déploiement pour attribuer un mot de passe au compte administrateur. Une fois que le mot de passe est configuré, vous pouvez vous connecter au pare-feu via l’adresse IP publique de Management.

Ci-dessous, les étapes nécessaires seront détaillées.
Etape 1 : Ouvrez un terminal Linux sur la machine de Lab

Etape 2 : Connectez-vous en ssh sur la VM-Series admin@ADRESSE_IP_PUBLIQUE_DU_FIREWALL -i MonVPC.pem
.. figure:: Create VPC-42.png

Etape 3 : Configurez le mot de passe admin en suivant la figure ci-dessous
.. figure:: Create VPC-43.png


Etape 4 : Sauvegardez les modifications via un commit et quittez le terminal Linux

Etape 5 : Naviguez sur le firewall virtuel avec l’adresse IP publique avec le login admin et le mot de passe configuré durant l’étape précédente

.. figure:: Create VPC-44.png







Configuration du pare-feu nouvelle génération

Configurer les Zones

Etape 1 : Allez dans Networks > Zones > Add

Etape 2 : Ajoutez une nouvelle zone nommée Untrusted et de type Layer3
.. figure:: Create VPC-45.png

Etape 3 : Ajoutez une deuxième zone nommée Trusted de type Layer3
.. figure:: Create VPC-46.png




Configurer un Profil de Management d’Interface

Etape 1 : Allez vers Network > Network Profiles > add et ajoutez un nouveau profil de gestion

Etape 2 : attribuez le nom PingProfile au profil de gestion, sélectionnez le Ping dans Networks Services et cliquez sur OK
.. figure:: Create VPC-47.png



Configurer les interfaces Ethernet1/1 et Ethernet1/2
Etape 1 : Allez dans Network > Interfaces > Ethernet1/1

Etape 2 : Dans Interface Type, sélectionnez Layer3

Etape 3 : Dans l’onglet Config, sélectionnez le routeur virtuel default et la zone de sécurité Untrusted

.. figure:: Create VPC-48.png

Etape 4 : Dans l’onglet IPv4, sélectionnez DHCP Client, cochez Enable et Automatically create default route pointing to default gateway provided by server

.. figure:: Create VPC-49.png

Etape 5 : Dans l’onglet Advanced, allez dans Management Profile, sélectionnez PingProfile et cliquez sur OK
.. figure:: Create VPC-50.png

Etape 6 : Ouvrez Ethernet1/2. Dans Interface Type, sélectionnez Layer3 et dans l’onglet Config, sélectionnez le routeur virtuel default et la zone de sécurité Trusted

.. figure:: Create VPC-51.png


Etape 7 : Dans l’onglet IPv4, sélectionnez DHCP Client, cochez Enable et décochez Automatically create default route pointing to default gateway provided by server

.. figure:: Create VPC-52.png

Etape 8 : Dans l’onglet Advanced, allez dans Management Profile, sélectionnez PingProfile et cliquez sur OK

.. figure:: Create VPC-53.png




Configurer les objets

Etape 1 : Créez un objet d’adresse en allant dans Objects > Addresses > Add, nommez l’objet
WebServerPrivate, sélectionnez IP Netmask comme Type et ajoutez l’adresse IP 10.2.5.11
.. figure:: Create VPC-54.png

Etape 2 : Créez un deuxième objet d’adresse en allant dans Objects > Addresses > Add, nommez l’objet WebServerPublic, sélectionnez IP Netmask comme Type et ajoutez l’adresse IP 10.2.10.10
.. figure:: Create VPC-55.png






Configuration Système du pare-feu

Dans cette section, la configuration système du firewall sera décrite. Cette configuration sera nécessaire pour que le firewall soit capable d’activer la licence dans la section suivante. La configuration de DNS, NTP, Hostname et Timezone est décrite ci-dessous.


Etape 1 : Allez dans Device > Setup > Management > General Setting, attribuez au firewall un nom dans le champ Hostname comme MonFirewallVirtuel, sélectionnez Europe/Paris dans TimeZone et validez
.. figure:: Create VPC-56.png

Etape 2 : Dans l’onglet Services > Services, ajoutez l’adresse 8.8.8.8 comme adresse du Primary DNS Server
.. figure:: Create VPC-57.png

Etape 3 : Dans l’onglet NTP, ajoutez l’adresse 0.fr.pool.ntp.org comme adresse de NTP Primaire
.. figure:: Create VPC-58.png




Activation de la licence (Auth-Code)

Utilisez le code d’autorisation (auth-code) que vous avez reçu par mail pour activer toutes les fonctionnalités de sécurité sur votre NGFW.

Etape 1 : Allez dans Devices > Licenses

Etape 2 : Cliquez sur Activate features using Authorization Code, entrez l’auth-code reçu par e-mail et validez

Etape 3 : Une fois la validation faite, cliquez sur Retrieve licence from licence server. Quelques secondes plus tard, toutes les licences seront activées
.. figure:: Create VPC-59.png





Configuration des règles de sécurité
Les étapes suivantes consistent à ajouter les bonnes règles de sécurité afin de vous permettre à la fois de gérer votre Serveur Web à distance (via ssh), d’accéder en HTTP vers le serveur Web depuis Internet et de laisser ce dernier sortir sur Internet pour télécharger et installer le package Apache. Vous allez configurer les mêmes règles de sécurité qui sont détaillées dans la figure suivante :
.. figure:: Create VPC-60.png

En plus des règles de sécurité, il est nécessaire de configurer les règles de NAT (source et destination).
La figure suivante décrit les règles de NAT à configurer sur le firewall.
.. figure:: Create VPC-61.png


Sauvegarder la configuration du pare-feu
Une fois la configuration terminée, un Commit est indispensable pour appliquer l’ensemble des
modifications.
.. figure:: Create VPC-62.png








Déploiement et configuration du serveur Web protégé par la VM-Series

Configurer une route par défaut pour le subnet Trusted_Subnet

Etape 1 : Allez dans Services > VPC > Routes tables > Trusted_RT > Routes > Edit Routes et ajoutez une route par défaut qui pointe vers l’interface Ethernet1/2 du NGFW virtuel déployé précédemment

Etape 2 : Sauvegardez les modifications via Save routes

.. figure:: Create VPC-63.png




Déployer le nouveau serveur web
Etape 1 : Allez dans Services > EC2 > Instances > Instances > Launch Instance. Dans Choose AMI sélectionnez Amazon Linux 2 AMI (HVM), SSD Volume Type

.. figure:: Create VPC-64.png

Etape 2 : Dans Choose Instance Type, sélectionnez le type t2.micro et cliquez sur Next : Configure Instance details
.. figure:: Create VPC-65.png

Etape 3 : Dans Configure Instance, sélectionnez le VPC MonVPC dans Network, sélectionnez le subnet Trusted_Subnet, sélectionnez Disable dans Auto-assign Public IP et laissez les autres paramètres par défaut

.. figure:: Create VPC-66.png

Etape 4 : Dans Networks interfaces, ajoutez l’adresse IP 10.2.5.11 comme adresse IP Primaire
.. figure:: Create VPC-67.png

Etape 5 : Dans cette étape, vous allez utiliser la fonctionnalité User Data d’AWS pour pousser un script d’automatisation du déploiement et de la configuration d’un serveur Web Apache sur votre Instance Linux. Il faut ainsi aller dans Advanced Details, sélectionner l’option As text et coller le script ci-dessous. Ensuite, cliquez sur Next: Add Storage

#!/bin/bash
yum install httpd -y
systemctl start httpd
systemctl stop firewalld
cd /var/www/html
echo " this is my site from WESTCON & Palo Alto Networks" > index.html


.. figure:: Create VPC-68.png

Etape 6: Dans Add Storage, cliquez sur Next Next : Add Tags (aucune modification)
Etape 7 : Dans Add Tags, cliquez sur Next : Configure Security Group
Etape 8 : Dans Configure Security Group, sélectionnez le groupe de sécurité Trusted_SG, et cliquez sur Review and Launch

.. figure:: Create VPC-69.png

Etape 9 : Dans Review and Launch, cliquez sur Launch

Etape 10 : Dans Select existing key pair or create a new key pair, choisissez l’option Choose an existing key pair, sélectionnez la paire de clés MonVPC, cochez I acknowledge... et cliquez sur Launch Instances
.. figure:: Create VPC-70.png



Accès sécurisé à mon Serveur Web hébergé dans AWS
Vous arrivez à l’étape finale du présent Lab. Vous pouvez ainsi tester la connectivité http vers votre serveur Web en naviguant vers l’adresse IP publique associée à l’interface Untrusted de votre firewall. Vous pouvez aussi aller consulter les logs dans la section Monitor de votre NGFW et tester d’autres fonctionnalités de sécurité disponibles sur ce dernier.

.. figure:: Create VPC-71.png






Suppression du VPC
Allez dans Services > EC2 > VPC > Your VPC, sélectionnez le VPC MonVPC ensuite allez dans Actions > Delete VPC et ensuite confirmez la suppression.

.. figure:: Create VPC-72.png

