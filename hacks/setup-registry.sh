az acr create --sku Basic --name ramiro --resource-group ramiro
az acr login --name ramiro

az acr credential show -n