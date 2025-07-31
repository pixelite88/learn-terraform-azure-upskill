- Terraform - Infrastructure as Code (IaC)
 Pozwala definiować infrastrukturę (np. zasoby w chmurze Azure) jako pliki tekstowe.

Dzięki temu można:
- Tworzyć i modyfikować infrastrukturę w sposób powtarzalny,
- Trzymać definicje infrastruktury w repozytorium Git (np. jako część CI/CD),
- Unikać błędów ręcznej konfiguracji.

Język: HashiCorp Configuration Language (HCL)
Dostawcy (providers): np. Azure, AWS, GCP. Tutaj używamy azurerm
Zasoby (resources): jednostki, które tworzysz (np. azurerm_storage_account)
Stan (state): Terraform przechowuje stan twojej infrastruktury w pliku terraform.tfstate, dzięki czemu wie, co już istnieje.

- App Service Plan – określa rozmiar i region dla Function App
- Storage Account – do trzymania plików + 3 kontenery blob
- Azure Static Web App – do hostowania frontendów
- Azure Function App – do logiki backendowej
- Application Insights – do monitorowania


[azurerm](https://github.com/hashicorp/terraform-provider-azurerm)
```
Lifecycle management of Microsoft Azure using the Azure Resource Manager APIs. maintained by the Azure team at Microsoft and the Terraform team at HashiCorp
```

25-07

- podział infrastruktury - function app (backend) , static-web-app (frontend), storage (wykorzystaj moved blocks)
- do czytania - https://developer.hashicorp.com/terraform/language/modules
              - https://developer.hashicorp.com/terraform/language/expressions/for
              - https://developer.hashicorp.com/terraform/language/expressions/conditionals
- block lifecycle
- terraform musi wykorzystywac remote backend


31.07

- zostaje modules/infrastructre, obok tego modułu nowy, moduł infrastructre ma wywoływać ww. moduły. Terraform przy terraform plan ma nie usuwać niczego. 
- czym się rózni locals vs variable (definicja i na przykładzie)

Zadanie 1: 
Refaktoryzacja modułów:
- blok `moved` -  pozwala zmieniać nazwę lub lokalizację zasobów/modułów bez destrukcji istniejącej infrastruktury 
-  moved mówi Terraformowi: „zasób z adresu from przeniósł się na adres to”, dzięki czemu stan jest automatycznie aktualizowany, a zasoby fizyczne pozostają nienaruszone


Remote backend:
- Remote backend oznacza, że stan Terraform (plik terraform.tfstate) jest przechowywany zdalnie, a nie lokalnie. W przypadku Azure, najczęściej wykorzystuje się do tego Azure Storage Account.

Zalety remote backend:
- Bezpieczeństwo - stan jest zabezpieczony w chmurze
- Współpraca - wiele osób może pracować na tej samej konfiguracji
- Blokowanie stanu - zapobiega konfliktom przy równoległej pracy
- Backup - automatyczne kopie zapasowe stanu

```
az group create --name cv-terraform-state-dev --location westeurope
```

```
az storage account create --name cvtfstatedev --resource-group cv-terraform-state-dev --sku Standard_LRS
```

```
az storage container create --name terraform-state --account-name cvtfstatedev
```


Local vs Variable
Variables (zmienne)
    - Służą jako parametry wejściowe dla modułu
    - Mogą być nadpisywane z zewnątrz (np. przez -var, pliki .tfvars, zmienne środowiskowe)
    - Deklarowane są w bloku variable
    - Mogą mieć wartości domyślne, typy i ograniczenia walidacji
    ```
        variable "environment" {
        type        = string
        default     = "dev"
        description = "Environment name (dev/prod)"
        validation {
            condition     = contains(["dev", "prod"], var.environment)
            error_message = "Environment must be dev or prod."
        }
    }
```

Locals (lokalne)
    - Są to stałe wewnętrzne modułu
    - Nie mogą być zmieniane z zewnątrz
    - Często używane do transformacji innych wartości
    - Służą do DRY (Don't Repeat Yourself)
    - Deklarowane w bloku locals

Blob Lifecycle:
- Blob lifecycle odnosi się do cyklu życia obiektów typu BLOB (Binary Large Object) — czyli dużych binarnych danych, takich jak pliki, obrazy, wideo

    Co definiuje:
    - Kiedy Zostaje utworzony – czyli przesłany (np. przez aplikację lub użytkownika).
    - Jak Przechowywany – w konkretnym stanie (np. jako Hot, Cool, Archive).
    - Jak Zmieniany – np. poprzez aktualizację, przenoszenie między warstwami, nadpisywanie.
    - Jak Usuwany – automatycznie (np. po czasie) lub ręcznie.

Blob Lifecycle Management w Azure:
    - Przeniesienie do tańszej warstwy (np. Hot → Cool → Archive) po określonym czasie.
    - Usunięcie nieużywanego bloba po np. 90 dniach.
    - Czyszczenie niekompletnych przesłań (stale blobs).
    - Zarządzanie wersjami i snapshotami.

    Dlaczego:
    - Oszczędność kosztów – starsze dane mogą być automatycznie przenoszone do tańszych warstw.
    - Zarządzanie przestrzenią – niepotrzebne bloby są usuwane.
    - Zgodność z politykami firmy/RODO – np. usuwanie plików po X dniach.


Block Lifecycle:



Modules:
- Moduł to zestaw plików Terraform (*.tf lub *.tf.json) znajdujących się w jednym katalogu. Każda konfiguracja Terraform to moduł — tzw. moduł root
- Moduły służą do pakowania i ponownego użycia konfiguracji infrastruktury — np. zestawu zasobów tworzących VPC, bazę danych czy klaster
    Rodzaje:
    - Moduł root — to moduł główny, definiowany przez pliki .tf w katalogu roboczym gdzie wykonujesz terraform apply 
    - Moduł child — folder/moduł wywoływany przez inny moduł za pomocą bloku module … { source = … }
    - Moduły lokalne (folder) oraz moduły zdalne z rejestrów publicznych/privatnych (Terraform Registry, VCS) 

    Kompozycja modułów i najlepsze praktyki
    - Preferowana jest płaska struktura modułów — root moduł łączy kilka child modułów zamiast zagnieżdżania zbyt głęboko
    - Moduły powinny reprezentować logiczne części infrastruktury — np. sieć, baza danych, konto storage — a nie pojedyncze zasoby
    - Moduły ułatwiają: organizację, standaryzację, ponowne użycie konfiguracji (DRY), abstrakcję oraz współpracę między zespołami

    Providery i wersjonowanie
    - Moduły deklarują wymagania dotyczące providerów (blok required_providers), co zapewnia kompatybilność wersji
    - Provider konfiguracje są globalne, ale można je przekazywać do child modułów jawnie (przez providers = {...}) lub korzystać z dziedziczenia niejawnego

    Publikowanie modułów
    - Moduły możesz udostępniać poprzez Terraform Registry (publiczny) lub prywatny rejestr np. w Terraform Cloud/Enterprise
    
        | Element                 | Opis                                                                          |
    | ----------------------- | ----------------------------------------------------------------------------- |
    | **Moduł (module)**      | Zestaw plików `.tf` traktowanych jako jednostka logiczna.                     |
    | **Root moduł**          | Główna konfiguracja projektu Terraform.                                       |
    | **Child moduł**         | Wywoływany przez inny moduł, umożliwia reużywalność i modularność.            |
    | **Struktura katalogu**  | `main.tf`, `variables.tf`, `outputs.tf`, `README.md`, opcjonalny `examples/`. |
    | **Wejścia/wyjścia**     | `variable` oraz `output` — trzeba zdefiniować dla konfiguracji zewnętrznej.   |
    | **Kompozycja modułów**  | Moduły łączone płasko (bez nadmiernego zagnieżdżania).                        |
    | **Provider management** | Wymagania wersji i jawne przypisywanie providerów w modułach.                 |
    | **Publikacja**          | Rejestry Terraform (publiczny/prywatny), wersjonowanie przez `version`.       |


For expressions:
- To sposób na przekształcanie kolekcji (list, setów, tuple, map lub obiektów) w inną kolekcję — np. poprzez filtrację lub modyfikację wartości
- Są składniowo podobne do zapytań w innych językach: for x in lista : wyrażenie
- Iterujemy po: 
    - listach, tuple,
    - setach,
    - mapach i obiektach Terraform.

Typ wynikowy: lista lub Mapa

Kolejność elementów
- Dla nieuporządkowanych typów (mapy, sety): Terraform porządkuje elementy alfabetycznie po kluczach.
- W zestawach stringów: sortowanie według wartości.
- Dla innych typów setów: kolejność może być arbitralna i zmienna. Możesz użyć toset(...), żeby zaznaczyć, że wynik jest nieuporządkowan