# Counter API on Azure App Service

A .NET 8 API with one endpoint, `GET /count`, which returns how many times it has been called. It runs as a Linux container on Azure App Service, with the infrastructure written in Bicep.

The original task is in [ASSIGNMENT.md](ASSIGNMENT.md).

## Repository layout

```
src/     .NET 8 API and Dockerfile
tests/   Unit tests
iac/     Bicep: main.bicep, modules/, parameters/ (dev, prod), bicepconfig.json
```

## Bugs fixed

**Dockerfile**

- `dotnet restore ".\CounterApi.csproj"` used a Windows path separator, so the image failed to build on Linux. Changed to `./CounterApi.csproj`.
- `EXPOSE 5000` didn't match the port the app listens on (8080, the .NET 8 default). Changed to `EXPOSE 8080`.

## Dockerfile improvements

- Removed the separate `dotnet build` step; `dotnet publish` already builds the project.
- Added a `.dockerignore` so local `bin/` and `obj/` folders aren't copied into the image build.

## Infrastructure

Resources: Log Analytics workspace, Application Insights, Container Registry, Linux App Service plan and a Web App for Containers.

- One module per resource type, each configured from the parameter file. Optional settings fall back to defaults.
- The Web App finds the plan, registry, Application Insights and workspace by key from the parameter file.
- Naming: `<company><project><environment>` with no hyphens, for example `docosoftcounterapidev`, because Container Registry names can't contain hyphens.
- Tags: a shared `environment` tag, plus optional tags per resource.
- The Web App pulls images with its managed identity (AcrPull); the registry admin user is disabled.
- HTTPS only, TLS 1.2, FTP disabled. Logs go to Log Analytics.
- `WEBSITES_PORT=8080` tells App Service which port the container listens on.

| | dev | prod |
|---|---|---|
| App Service plan | B1 | P0V4 |
| Container Registry | Basic | Standard |
| Log retention | 30 days | 90 days |

## Trade-offs and assumptions

- **Region:** deployed to UK South because of capacity constraints in West Europe and North Europe.
- **Prod:** P0V4 App Service plan.
- **Single instance:** the app is lightweight (a single counter endpoint), so one instance is enough.
- **Linter warning:** `diagnosticSettings` uses the newest API version available (a preview); the linter warning about it is expected.
