# TP1 bis - AWS Lambda avec LocalEmu

Le même principe que le TP1, mais avec AWS. Tout tourne en local grâce à LocalEmu, sans compte AWS.

## Fonctionnement

Client HTTP → API Gateway → lambda-http → SQS → lambda-sqs → DynamoDB

1. API Gateway expose une route HTTP et la passe à lambda-http.
2. lambda-http vérifie le JSON, lui donne un id et le met dans la file SQS. Elle répond 202 tout de suite.
3. SQS garde le message en attente.
4. lambda-sqs se lance toute seule quand un message arrive et l'enregistre dans DynamoDB.
5. DynamoDB stocke les messages dans la table messages.

Les deux Lambda ne s'appellent jamais, elles passent par la file.

## Prérequis

Docker, Node.js et Python entre 3.11 et 3.14. Python 3.12 marche bien, les versions plus récentes font planter l'installation de LocalEmu.

## Lancer le projet

1. Créer un environnement Python avec python3.12 -m venv ~/localemu-env puis l'activer avec source ~/localemu-env/bin/activate.
2. Installer LocalEmu avec pip install "localemu[runtime]".
3. Démarrer l'émulateur avec localemu start et laisser ce terminal ouvert.
4. Dans un autre terminal avec le même environnement activé, lancer ./setup.sh. Il crée la file, la table, les deux Lambda, le lien entre SQS et lambda-sqs, et l'API. Il affiche l'URL de l'API à la fin.

Les ressources disparaissent quand on arrête LocalEmu, il suffit de relancer ./setup.sh.

## Tester

Lancer ./test.sh. Il fait un appel valide, deux appels à la suite et deux appels invalides, puis il affiche le contenu de la table et les logs de lambda-sqs.

Le résultat d'un vrai lancement est dans preuves.txt. On y voit que le compte utilisé est 000000000000, donc l'émulateur et pas AWS. Juste après le premier appel la table est encore vide, alors que l'API a déjà répondu. Les appels invalides reçoivent une erreur 400 et n'arrivent jamais dans la file.

## Questions du TP

Pourquoi ne pas écrire dans DynamoDB depuis lambda-http ? Pour répondre vite au client et ne pas le faire attendre. Si la base est lente ou en panne, la requête ne plante pas, le message attend dans la file.

À quoi sert SQS ? Les deux fonctions sont indépendantes. On peut modifier ou faire tomber lambda-sqs sans toucher à l'API, et SQS relance les messages en échec.

Et si un message est traité deux fois ? Avec SQS ça peut arriver, on risquerait d'avoir des doublons. Ici l'id est créé par lambda-http avant l'envoi, donc un deuxième traitement réécrit la même ligne au lieu d'en créer une nouvelle.

Différences avec Azure ? Le principe est le même. Lambda remplace Functions, SQS remplace Queue Storage et DynamoDB remplace Table Storage. Avec Azure, les bindings écrivent dans la file et la table sans code. Avec AWS, on utilise le SDK dans le code et il faut créer soi-même chaque ressource et le lien entre SQS et la Lambda.

## Limites et problèmes rencontrés

LocalEmu ne s'installe pas avec Python 3.15, il a fallu repasser en 3.12.

Dans la Lambda, le SDK SQS envoyait les messages à l'adresse de la file au lieu de l'émulateur. L'option useQueueUrlAsEndpoint à false règle ça.

Le premier appel prend quelques secondes parce que LocalEmu doit démarrer le conteneur Docker de la Lambda.
