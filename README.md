## Vulnérabilités exploitées

AttackFlip correspond à un flip pour sepolia

Assurez-vous que le contrat HackMeIfYouCan est déployé sur le réseau. Modifiez l'adresse du contrat déployé dans le script d'attaque si nécessaire.

hackMeContract = HackMeIfYouCan(0x9D29D33d4329640e96cC259E141838EB3EB2f1d9);

```sh
forge script script/Attack --tc Attack --broadcast --rpc-url <URL_DU_RESEAU>
```

## Vulnérabilités exploitées

### AttackFlip

Le script AttackFlip correspond à une exploitation spécifique pour le réseau Sepolia, permettant d'exploiter les prédictions des blocs pour gagner des flips consécutifs.

Contenu des attaques
Le répertoire ./scripts contient les différents scripts d'attaque. Le script principal, Attack, couvre les principales vulnérabilités suivantes :

- flip

La fonction flip ne vérifie pas correctement les conditions du bloc précédent, permettant une exploitation via des appels prédictifs.

- contribute

La fonction contribute permet de devenir le propriétaire en envoyant une petite quantité d'Ether.

- goTo

La fonction goTo ne vérifie pas correctement si l'étage est le dernier, permettant de falsifier les étages.

- sendKey

La fonction sendKey peut être exploitée en lisant directement la clé du stockage.

- sendPassword

La fonction sendPassword peut être exploitée en lisant directement le mot de passe du stockage.

- transfer

La fonction transfer peut être exploitée pour obtenir des marques en transférant des fonds.

- receive

La fonction receive peut être exploitée via une attaque de réentrance.

- addPoint

La fonction permet d'avoir un point gratuit si on est pas l'origin.
