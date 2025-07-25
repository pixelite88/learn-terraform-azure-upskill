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