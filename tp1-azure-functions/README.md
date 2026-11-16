# TP1 - Azure Functions

Petite architecture serverless qui tourne en local, sans compte Azure. Azurite émule le stockage Azure.

## Architecture

```
POST /api/httpTrigger → httpTrigger → Queue "messages" → queueTrigger → Table "messages"
```

| Fonction | Déclencheur | Rôle |
|---|---|---|
| `httpTrigger` | Requête HTTP POST | Envoie le JSON reçu dans la queue |
| `queueTrigger` | Message dans la queue | Écrit le message dans la table |

Les deux fonctions ne s'appellent pas : elles passent par la queue, via les bindings Azure.

## Lancer en local

Prérequis : Node.js et pnpm. Core Tools (`func`) et Azurite sont installés avec le projet.

```bash
pnpm install
pnpm azurite   # terminal 1
pnpm start     # terminal 2
```

Tester :

```bash
curl -X POST http://localhost:7071/api/httpTrigger \
  -H "Content-Type: application/json" \
  -d '{"nom":"Jeremy","message":"Bonjour"}'
```

Les logs de `pnpm start` montrent les deux fonctions s'exécuter. La ligne est visible dans la table `messages`, par exemple avec Azure Storage Explorer.
