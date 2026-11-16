# TP1 - Azure Functions

Une petite architecture serverless qui tourne entièrement en local, sans compte Azure. Le stockage Azure est simulé par Azurite, un émulateur fourni par Microsoft.

## Comment ça marche

Le projet contient deux fonctions qui ne se parlent jamais directement : elles communiquent uniquement par une file de messages (une Queue).

1. La première fonction, httpTrigger, reçoit une requête HTTP avec des données en JSON et les dépose dans la Queue.
2. La seconde fonction, queueTrigger, se déclenche toute seule dès qu'un message arrive dans la Queue, puis l'enregistre dans une table (Table Storage).

Les connexions vers la Queue et la Table passent par les bindings Azure, sans code d'accès écrit à la main.

## Lancer le projet

Il faut avoir Node.js et pnpm installés. Le reste (l'outil Azure Functions et Azurite) s'installe avec le projet.

1. Installer les dépendances avec `pnpm install`.
2. Dans un premier terminal, démarrer Azurite avec `pnpm azurite`.
3. Dans un second terminal, démarrer les fonctions avec `pnpm start`.

## Tester

Envoyer une requête POST sur http://localhost:7071/api/httpTrigger avec un petit JSON dans le corps, par exemple un nom et un message. On peut le faire avec curl, Postman ou Bruno.

Dans les logs du second terminal, on voit la première fonction s'exécuter, puis la seconde juste après. La donnée se retrouve dans la table « messages », qu'on peut consulter avec Azure Storage Explorer.
