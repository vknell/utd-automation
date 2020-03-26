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


Etape 3 : Remplissez le nom du VPC, le sous réseau, laissez les autres paramètres par défaut et
cliquez sur Save pour sauvegarder :

.. figure:: Create VPC-3.png

Etape 4 : Sélectionnez le VPC MonVPC et allez dans Actions > Edit DNS hostnames

.. figure:: Create VPC-4.png

Etape 5 : Dans Edit DNS hostnames, cochez le bouton enable et sauvegardez

.. figure:: Create VPC-5.png










Création des sous réseaux AWS (subnets)

Le bloc de réseaux IPv4 créé avec le VPC sera maintenant segmenté en plusieurs sous réseaux. Vous
pouvez créer des sous-réseaux ayant des plages d’adresses IP qui feront partis du bloc IPv4 du VPC.
Les sous réseaux seront utilisés comme suit :

.. figure:: Create VPC-6.png

Etape 1XXXXX : allez dans VPC > Subnets > Create subnet

.. figure:: Create VPC-7.png

Etape 2XXXXX : Renseignez le nom, le VPC (MonVPC), la zone de disponibilité et la plage du sous réseau en
se basant sur le tableau ci-dessus pour le subnet Management_Subnet et sauvegardez la configuration

.. figure:: Create VPC-8.png

Etape 3XXXXXX : Répétez l’étape précédente pour les deux autres sous réseaux Untrusted_Subnet et
Trusted_Subnet

.. figure:: Create VPC-9.png














Création d’une passerelle Internet IGW
La création d’un passerelle Internet est indispensable pour permettre au VPC de se connecter à
Internet. Une fois que la passerelle est créée, il sera nécessaire de l’attacher à un VPC.


Etape 1 : Allez dans VPC > Internet Gateways > Create internet gateway et utilisez MonIGW comme
nom

.. figure:: Create VPC-10.png

Etape 2 : Sélectionnez l’IGW MonIGW et ensuite allez dans Actions > Attach to VPC


.. figure:: Create VPC-11.png


Etape 3 : Sélectionner le VPC MonVPC et sauvegarder

.. figure:: Create VPC-12.png












Création des tables de routage
Les tables de routage vous permettent d'attribuer une connectivité telle que des passerelles Internet
et des passerelles par défaut à des groupes spécifiques de points de terminaison. Rappelez-vous que
tous les points d'extrémité dans le VPC peuvent se connecter de manière native à n'importe quel autre
point d'extrémité dans le bloc CIDR VPC affecté (exemple : 10.2.0.0/16). Cela ne peut pas être modifié
par une table de routage. Il existe une table de routage principale créée par défaut pour un VPC, et
tous les sous-réseaux qui ne sont pas affectés à une table de routage personnalisée sont affectés à la
table de routage principale du VPC. Par défaut, la table de routage principale route uniquement vers
le bloc CIDR VPC. Les tables de routage peuvent contrôler toute connectivité de sous-réseau IP en
dehors du bloc CIDR VPC.
Bien que les tables de routage Untrusted_RT (publique) et Management_RT (table de routage du
subnet de Management) soient programmées de la même manière ci-dessous, elles sont réparties
séparément car vous pouvez personnaliser votre table de routage Management_RT pour accéder
uniquement aux destinations de gestion sélectionnées via l'IGW par rapport à une table ouverte par
défaut de 0.0.0.0/0. Il existe une table de routage de serveur Web pour chaque zone de disponibilité
et une route par défaut sera ajoutée plus loin dans ce guide, une fois les pare-feux programmés et
opérationnels.
Ci-dessous, les tables de routage à créer sont décrites dans le tableau ci-dessous :

.. figure:: Create VPC-13.png

Etape 1 : Créez la table de routage Management_RT en allant vers Services > VPC > Virtual Private
Cloud > Routes Tables > Create route table
Etape 2 : Entrez le nom de la table de routage, sélectionnez le VPC MonVPC et sauvegardez


.. figure:: Create VPC-14.png

Etape 3 : Sélectionnez la table de routage Management_RT

.. figure:: Create VPC-15.png

Etape 4 : Allez dans Routes pour ajouter une nouvelle route par défaut en cliquant sur Edit Routes

.. figure:: Create VPC-16.png


Etape 5 : Ajoutez la nouvelle route 0.0.0.0/0, sélectionnez la passerelle MonIGW au niveau du Target
et sauvegardez les changements

.. figure:: Create VPC-17.png

Etape 6 : Allez dans Subnet Associations > Edit subnet associations

.. figure:: Create VPC-18.png

Etape 7 : Sélectionnez Management_Subnet et sauvegardez

.. figure:: Create VPC-19.png

Etape 8 : Répétez les étapes 1 à 7 pour créer, modifier la table de routage et associer le subnet pour la
table de routage Untrusted_RT


Etape 9 : Créez la table de routage Trusted_RT et associez le subnet Trusted_Subnet à cette dernière.
Attention : Pas de route par défaut pour la table de routage Trusted_RT, cette route par défaut sera
ajoutée ultérieurement.












Création des groupes de sécurité (Security Groups)
Lorsque vous créez une instance de calcul AWS Elastic Compute (EC2) pour exécuter une instance de
machine virtuelle, vous devez attribuer un groupe de sécurité (SG) nouveau ou existant à cette
instance. Les groupes de sécurité fournissent un pare-feu à état de couche 4 pour le contrôle des
adresses IP sources/destinations et les ports qui sont autorisés à destination ou en provenance des
instances associées. Les SG sont appliqués aux interfaces réseau. Jusqu'à cinq SG peuvent être associés
à une interface réseau. L'accès sortant par défaut est autorisé pour permettre l'ensemble du trafic de
sortir vers tous les lieux ; vous pouvez toutefois la personnaliser en fonction de vos opérations. Par
défaut, la liste d'accès aux services entrants est définie de manière à ne pas autoriser le trafic ; vous
modifierez cette configuration en fonction des tableaux ci-dessous.
Vous configurez les groupes de sécurité à affecter au pare-feu de la VM-Series et au serveur Web :
•
•
•
Untrusted (interface publique du pare-feu) : Initialement, tout le trafic sera autorisé vers les
périphériques du groupe de sécurité publique, par exemple le groupe de sécurité publique du
pare-feu, et le pare-feu contrôlera le trafic grâce à des politiques de sécurité. Vous pouvez
restreindre l’accès au réseau seulement aux ports de la couche 4 n nécessaires. Ce dernier
réduira la charge de trafic inutile qui pourra arriver sur l’interface publique du firewall.
Management du Firewall : autoriser les ports nécessaires pour pouvoir gérer votre firewall
comme l’ICMP, le SSH et le HTTPS
Serveur Web : Autoriser les flux nécessaires pour les flux de gestion du serveur web et
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
