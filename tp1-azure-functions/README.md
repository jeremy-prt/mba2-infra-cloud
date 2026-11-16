# TP1 - Azure Functions

Une petite appli serverless qui tourne en local, sans compte Azure. Azurite simule le stockage Azure.

## Fonctionnement

1. httpTrigger reçoit une requête HTTP et met les données dans une Queue.
2. queueTrigger se lance quand un message arrive dans la Queue et l'enregistre dans une Table.

Les deux fonctions ne s'appellent jamais, elles passent par la Queue.

## Lancer le projet

Il faut Node.js et pnpm.

1. Installer avec `pnpm install`.
2. Lancer Azurite avec `pnpm azurite`.
3. Dans un autre terminal, lancer les fonctions avec `pnpm start`.

## Tester

Envoyer un POST avec un JSON sur http://localhost:7071/api/httpTrigger. Les deux fonctions s'affichent dans les logs et la donnée arrive dans la table « messages ».
